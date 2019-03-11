require 'mpf/tree'
require 'mpf/yaml'

module MPF

  module UI

    class View

      include External::Text
      include YAML

      def initialize(options = {})
        @path = options[:path]
        @dir_path = File.dirname(@path)
        @file_name = File.basename(@path)
      end

      def compile(options = {})
        source_model, errors = Tree.parse(from: :xml, text: file(@path))
        if errors.empty?
          options[:locales].each do |locale_name, locale_config|
            text = emit_target_code(source_model: source_model, locale: locale_config)
            path = "#{options[:target_dir_path]}/#{locale_name}/#{@file_name}"
            write_file(path, text.strip)
          end
        else
          errors.each { |error| print "\nError: #{error}" }
        end
      end

      def emit_target_code(options = {})
        TargetEmitter.new(options.dup.merge(config: config)).emit_code.render(to: :xml)
      end

      def config
        config_path = "#{@dir_path}/#{File.basename(@file_name, '.*')}.yml"
        if File.exists? config_path
          yaml_file(config_path)
        else
          {}
        end
      end

      class TargetEmitter < Tree::Emitter

        KEY_MARKER = ':'.freeze
        JSON_PATH_MARKER = '$'.freeze

        def initialize(options = {})
          super(options[:source_model])
          @config = options[:config]
          @locale = options[:locale]
          @key = nil
          @value = nil
          @tree_path = ''
        end

        def emit_node(syntax, node)
          if variable?(node)
            enter_scope node
          elsif node.is_a? Tree::Node
            @tree_path += ".#{node.name}"
          end

          if orphan_text? node
            emit_label syntax, node
          elsif orphan_expression? node
            emit_expression syntax, node
          elsif @value.is_a? Array and node.children.any?
            emit_children syntax, node.children
          else
            super syntax, evaluated(node)
          end

          if variable?(node)
            exit_scope node
          elsif node.is_a? Tree::Node
            @tree_path = @tree_path[0..-(node.name.length + 2)]
          end
        end

        def emit_label(syntax, node)
          new_line syntax
          emit_node syntax, labeled(node)
          new_line syntax
        end

        def emit_expression(syntax, node)
          extracted_expressions(node).each { |subnode| emit_node(syntax, subnode) }
        end

        def emit_children(syntax, children)
          children = children[1..-1] if empty_node? children[0]
          children = children[0..-2] if empty_node? children[-1]
          items = @value
          items.each do |value|
            @value = value
            children.each do |child|
              emit_node syntax, child
              new_line syntax
            end
          end
        end

        def new_line(syntax)
          syntax.visitor.new_line if syntax.visitor.is_a? External::Text::Printer
        end

        def split_children(children)
          if empty_node? children[0]
            first = children[0]
            children = children[1..-1]
          end
          if empty_node? children[-1]
            children = children[0..-2]
          end
          [first, children]
        end

        def empty_node?(node)
          node.is_a? String and node.strip.empty?
        end

        def enter_scope(node)
          raise "Expected a node but found: #{node.inspect}" unless node.is_a? Tree::Node

          name = node.name
          return unless name.start_with? KEY_MARKER

          @key = node.name[1..-1]
          @value = @config[@key]
        end

        def exit_scope(node)
          raise "Expected a node but found: #{node.inspect}" unless node.is_a? Tree::Node

          name = node.name
          return unless @key == name[1..-1]

          @key = nil
          @value = nil
        end

        def orphan_expression?(node)
          text? node and node.include? JSON_PATH_MARKER and not under? 'expression'
        end

        def orphan_text?(node)
          text? node and not under? 'label' and not under? 'expression'
        end

        def text?(node)
          node.is_a? String and not empty_node? node
        end

        def under?(node_name)
          @tree_path.end_with? ".#{node_name}"
        end

        def variable?(node)
          node.is_a? Tree::Node and node.name.start_with? KEY_MARKER
        end

        def extracted_expressions(node)
          tokens = tokenized_expressions_of(node)
          expected "Expected JSON Path or some text but found: #{text.inspect}" unless tokens.any?

          expressions_of(tokens)
        end

        def tokenized_expressions_of(node)
          tokenizer = External::Text::Tokenizer.new(
            rules: {
              expr: /\$\.?([A-Za-z][A-Za-z0-9]*(\.[A-Za-z][A-Za-z0-9]*)*)?/,
              text: /[^$]*/
            }
          )
          tokenizer.tokenize(node)
        end

        def expressions_of(tokens)
          tokens.map do |token|
            if token.category == :text
              token.text
            else
              expression_node(token.text)
            end
          end
        end

        def expression_node(text)
          Tree::Node.new(
            'expression',
            { 'language' => 'JSONPath' },
            [text]
          )
        end

        def labeled(node)
          raise "Expected text node but found: #{node.inspect}" unless text? node

          Tree::Node.new('label', {}, [node])
        end

        def evaluated(node)
          if node.is_a? Tree::Node
            attributes = node.attributes.map { |key, value| [key, env_sub(key, value)] }.to_h
            Tree::Node.new(node.name.dup, attributes, node.children.dup)
          else
            node
          end
        end

        def env_sub(attrib_name, attrib_value)
          attrib_value = attrib_value.sub(':.', @value) if @value
          locale_sub(attrib_name, attrib_value)
        end

        def locale_sub(attrib_name, attrib_value)
          keys = attrib_value.scan(/(%(\.?[A-Za-z][A-Za-z0-9]*)+)/)
          raise "Expected array but found: #{keys}" unless keys.is_a? Array

          locale_prefix = "#{@tree_path[1..-1]}.#{attrib_name}"

          keys = keys.map { |key| key[0] }
          keys.reduce(attrib_value) do |value, key|
            locale_key = key.start_with?('%.') ? locale_prefix + key[1..-1] : key[1..-1]
            locale_value = locale_value_of(locale_key)
            locale_value ? value.sub(key, locale_value) : value
          end
        end

        def locale_value_of(key)
          keys = key.split('.')
          keys.reduce(@locale) { |locale, key| locale[key] }
        end

      end

    end

    class Module

      include YAML

      def initialize(options = {})
        path = options[:path] || Dir.pwd
        root_dir_path = Pathname.new(path).absolute? ? path : "#{Dir.pwd}/#{path}"
        @root_dir = Dir.new(root_dir_path)

        @source_dir = Dir.new("#{@root_dir.path}/source")
        @views_dir = Dir.new("#{@source_dir.path}/views")

        @locales_dir_path = "#{@source_dir.path}/locales"
      end

      def compile(options = {})
        target_dir_path = options[:target_dir_path] || "#{@root_dir.path}/target"

        view_names.each do |view_name|
          print "Compiling: #{view_name}\n"
          view(view_name).compile target_dir_path: target_dir_path, locales: locales
        end
      end

      def locale_names
        Dir["#{@locales_dir_path}/*.#{YAML::EXT}"].map do |path|
          File.basename(path, ".#{YAML::EXT}")
        end
      end

      def locales
        locale_names.map do |locale_name|
          @locale_file_path = "#{@locales_dir_path}/#{locale_name}.#{YAML::EXT}"
          [locale_name, File.exists?(@locale_file_path) ? yaml_file(@locale_file_path) : {}]
        end.to_h
      end

      def view(name)
        View.new(path: "#{@views_dir.path}/#{name}.xml")
      end

      def view_names
        Dir["#{@views_dir.path}/*.#{XML::EXT}"].map do |path|
          File.basename(path, ".#{XML::EXT}")
        end
      end

    end

    def self.module(options = {})
      Module.new(options)
    end

  end

end
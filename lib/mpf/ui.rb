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

        def initialize(options = {})
          super(options[:source_model])
          @config = options[:config]
          @locale = options[:locale]
          @key = nil
          @value = nil
          @locale_prefix = ''
        end

        def emit_node(syntax, node)
          if variable?(node)
            enter_scope(node)
          elsif node.is_a? Tree::Node
            @locale_prefix += ".#{node.name}"
          end

          if @value.is_a? Array and node.children.any?
            children = node.children
            children = children[1..-1] if empty_node? children[0]
            children = children[0..-2] if empty_node? children[-1]
            items = @value
            items.each do |value|
              @value = value
              children.each do |child|
                emit_node(syntax, child)
                syntax.visitor.new_line if syntax.visitor.is_a? External::Text::Printer
              end
            end
          else
            super(syntax, evaluated(node))
          end

          if variable?(node)
            exit_scope(node)
          elsif node.is_a? Tree::Node
            @locale_prefix = @locale_prefix[0..-(node.name.length + 2)]
          end
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

        def variable?(node)
          node.is_a? Tree::Node and node.name.start_with? KEY_MARKER
        end

        def evaluated(node)
          if node.is_a? Tree::Node
            attributes = node.attributes.map { |key, value| [key, env_sub(node, key, value)] }.to_h
            Tree::Node.new(node.name.dup, attributes, node.children.dup)
          else
            node
          end
        end

        def env_sub(node, attrib_name, attrib_value)
          attrib_value = attrib_value.sub('$', @value)
          locale_sub(node, attrib_name, attrib_value)
        end

        def locale_sub(node, attrib_name, attrib_value)
          keys = attrib_value.scan(/%[A-Za-z.][A-Za-z0-9]*/)
          raise "Expected array but found: #{keys}" unless keys.is_a? Array

          locale_prefix = "#{@locale_prefix[1..-1]}.#{attrib_name}"

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
        @root_dir = Dir.new("#{Dir.pwd}/#{options[:path]}")

        @source_dir = Dir.new("#{@root_dir.path}/source")
        @views_dir = Dir.new("#{@source_dir.path}/views")

        @locales_dir_path = "#{@source_dir.path}/locales"
        @target_dir_path = "#{@root_dir.path}/target"
      end

      def compile
        view_names.each do |view_name|
          view(view_name).compile target_dir_path: @target_dir_path, locales: locales
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
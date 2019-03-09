require 'mpf/tree'
require 'mpf/yaml'

module MPF

  module UI

    class View

      include External::Text
      include YAML

      def initialize(options = {})
        path = options[:path]
        @dir_path = File.dirname(path)
        @file_name = File.basename(path)
        @source_model, @errors = Tree.parse(from: :xml, text: file(path))
      end

      def generate(target_dir_path)
        if @errors.empty?
          path = "#{target_dir_path}/#{@file_name}"
          text = target_code.render(to: :xml)
          write_file(path, text.strip)
        else
          @errors.each { |error| print "\nError: #{error}" }
        end
      end

      def target_code
        TargetEmitter.new(@source_model, target_options).emit_code
      end

      def target_options
        { config: target_config, locale: target_locale }
      end

      def target_config
        config_path = "#{@dir_path}/#{File.basename(@file_name, '.*')}.yml"
        if File.exists? config_path
          yaml_file(config_path)
        else
          {}
        end
      end

      def target_locale
        { "%bills" => "_bills" }
      end

      class TargetEmitter < Tree::Emitter

        KEY_MARKER = ':'.freeze

        def initialize(root, options = {})
          super(root)
          @config = options[:config]
          @locale = options[:locale]
          @key = nil
          @value = nil
        end

        def emit_node(syntax, node)
          enter_scope(node) if node.is_a? Tree::Node

          if @value.is_a? Array
            items = @value
            items.each do |value|
              @value = value
              node.children
                  .map { |child| evaluated(child) }
                  .each { |child| super(syntax, child) }
            end
          else
            super(syntax, evaluated(node))
          end

          exit_scope(node) if node.is_a? Tree::Node
        end

        def enter_scope(node)
          raise "Expected a node but found: #{node.inspect}" unless node.is_a? Tree::Node

          name = node.name
          return unless name.start_with? KEY_MARKER

          @key = name[1..-1]
          @value = @config[@key]
        end

        def exit_scope(node)
          raise "Expected a node but found: #{node.inspect}" unless node.is_a? Tree::Node

          name = node.name
          return unless @key == name[1..-1]

          @key = nil
          @value = nil
        end

        def evaluated(node)
          if node.is_a? Tree::Node
            attributes = node.attributes.map { |key, value| [key, env_sub(value)] }.to_h
            Tree::Node.new(node.name.dup, attributes, node.children.dup)
          else
            node
          end
        end

        def env_sub(value)
          result = value.sub('$', @value)
          locale_sub(result)
        end

        def locale_sub(value)
          keys = value.scan(/%[A-Za-z.][A-Za-z0-9]*/)
          raise "Expected array but found: #{keys}" unless keys.is_a? Array

          keys.reduce(value) do |value, key|
            @locale[key] ? value.sub(key, @locale[key]) : value
          end
        end

      end

    end

    class Module

      include YAML

      CONFIG_FILE = 'module.yml'.freeze

      def initialize(options = {})
        @root_dir = Dir.new("#{Dir.pwd}/#{options[:path]}")

        @source_dir = Dir.new("#{@root_dir.path}/source")
        @views_dir = Dir.new("#{@source_dir.path}/views")

        @target_dir_path = "#{@root_dir.path}/target"

        @config = yaml_file("#{@root_dir.path}/#{CONFIG_FILE}")
      end

      def compile
        Dir.mkdir @target_dir_path unless Dir.exists? @target_dir_path
        view(@config['main-view']).generate @target_dir_path
      end

      def view(name)
        View.new(path: "#{@views_dir.path}/#{name}.xml")
      end

    end

    def self.module(options = {})
      Module.new(options)
    end

  end

end
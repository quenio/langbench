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
          text = Tree.emit(from: target_model).render(to: :xml)
          write_file(path, text.strip)
        else
          @errors.each { |error| print "\nError: #{error}" }
        end
      end

      def target_model
        # config_path = "#{@dir_path}/#{File.basename(@file_name, '.*')}.yml"
        # if File.exists? config_path
        #   config = yaml_file(config_path)
        # else
        #   config = nil
        # end
        builder = TargetBuilder.new
        Tree.emit(from: @source_model).evaluate visitor: builder
        builder.root
      end

      class TargetBuilder < Tree::Builder

        def enter_node(name, attributes = {}, &block)
          super(name, attributes, &block)
        end

        def exit_node(name, attributes = {}, &block)
          super(name, attributes, &block)
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
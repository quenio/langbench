require 'xml'

module MPF

  module TreeLang

    class Syntax < Language::Internal::Syntax

      def node(name, attributes = {}, &block)
        @visitor.enter_node(name, attributes, &block)
        if block
          value = yield
          visit_content(value) if value
        end
        @visitor.exit_node(name, attributes, &block)
        nil
      end

      def content(value)
        @visitor.visit_content(value)
        nil
      end

    end

    class Node

      attr_reader :name
      attr_reader :attributes
      attr_reader :children

      def initialize(name, attributes)
        @name = name
        @attributes = attributes
        @children = []
      end

    end

    class Builder

      include Language::Visitor

      attr_reader :root

      def initialize
        @parent = []
      end

      def enter_node(name, attributes = {}, &block)
        node = Node.new(name, attributes)
        @parent.last.children << node unless @parent.empty?
        @parent.push node
      end

      def exit_node(name, _attributes = {}, &block)
        @root = @parent.pop
      end

      def visit_content(value)
        @parent.last.children << value
      end

    end

    class Emitter

      attr_reader :root

      def initialize(root)
        @root = root
      end

      def emit_code
        emitter = self
        TreeLang.source do
          emitter.emit_node(self, emitter.root)
        end
      end

      def emit_node(syntax, node)
        if node.is_a? Node
          emitter = self
          syntax.node(node.name, node.attributes) do
            node.children.each { |child| emitter.emit_node(syntax, child) }
            nil
          end
        else
          syntax.content(node)
        end
      end

    end

    class Source

      def initialize(&source_code)
        @source_code = source_code
      end

      def print(options)
        TreeLang.print(options, &@source_code)
      end

      def render(options)
        TreeLang.render(options, &@source_code)
      end

      def build
        TreeLang.build(&@source_code)
      end

    end

    def self.source(&source_code)
      Source.new &source_code
    end

    def self.emit(options = {})
      model = options[:from]
      emitter = Emitter.new(model)
      emitter.emit_code
    end

    def self.build(&source_code)
      builder = Builder.new
      evaluate visitor: builder, &source_code
      builder.root
    end

    @syntax = { xml: XML::Syntax }

    def self.parse(options = {})
      # builder = Builder.new
      language = options[:from]
      syntax = @syntax[language].new
      errors = syntax.parse(text: options[:text], visitor: Language::External::ParseTree::Printer.new)
      # [builder.root, errors]
      [nil, errors]
    end

    @printer = { xml: XML::Printer }

    def self.print(options = {}, &source_code)
      format = options[:to]
      evaluate visitor: @printer[format].new, &source_code
    end

    @renderer = { xml: XML::Renderer }

    def self.render(options = {}, &source_code)
      format = options[:to]
      renderer = @renderer[format].new
      evaluate visitor: renderer, &source_code
      renderer.text
    end

    def self.evaluate(options = {}, &source_code)
      Syntax.evaluate visitor: options[:visitor], &source_code
    end

  end

end



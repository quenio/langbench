require 'xml'

module TreeLang

  class InternalSyntax

    def initialize(options = {})
      @visitor = options[:visitor]
    end

    def node(name, attributes = {}, &block)
      @visitor.visit_node(name, attributes, &block)
      nil
    end

    def content(value)
      @visitor.visit_content(value)
      nil
    end

    def evaluate(&source_code)
      instance_eval &source_code
    end

  end

  module Model

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

      include Visitor

      attr_reader :root

      def initialize
        @parent = []
      end

      def enter_node(name, attributes, &block)
        node = Node.new(name, attributes)
        @parent.last.children << node unless @parent.empty?
        @parent.push node
      end

      def exit_node(name, _attributes, &block)
        @root = @parent.pop
      end

      def visit_content(value)
        @parent.last.children << value
      end

    end

  end

  def self.build(&source_code)
    builder = Model::Builder.new
    visit visitor: builder, &source_code
    builder.root
  end

  @printer = { xml: XML::Printer }

  def self.print(options = {}, &source_code)
    format = options[:to]
    visit visitor: @printer[format].new, &source_code
  end

  @renderer = { xml: XML::Renderer }

  def self.render(options = {}, &source_code)
    format = options[:to]
    renderer = @renderer[format].new
    visit visitor: renderer, &source_code
    renderer.text
  end

  def self.visit(options = {}, &source_code)
    InternalSyntax.new(visitor: options[:visitor]).evaluate &source_code
  end

  class CodeEmitter

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
      if node.is_a? Model::Node
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

  def self.emit(options = {})
    model = options[:from]
    emitter = CodeEmitter.new(model)
    emitter.emit_code
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

end


# frozen_string_literal: true

#--
# Copyright (c) 2019 Quenio Cesar Machado dos Santos
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software
# and associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute,
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++
#

require 'lang_bench/internal'
require 'lang_bench/xml'

module LangBench
  module Tree
    class Syntax < Internal::Syntax
      def node(name, attributes = {}, &block)
        @visitor.enter_node(name, attributes, &block)
        if block
          value = yield
          @visitor.visit_content(value) if value
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

      def initialize(name, attributes, children = [])
        @name = name
        @attributes = attributes
        @children = children
      end
    end

    class Builder
      include Meta::Visitor

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
        Tree.source do
          emitter.emit_node(self, emitter.root)
        end
      end

      def emit_node(syntax, node)
        if node.is_a? Node
          emitter = self
          if node.children.any?
            syntax.node(node.name, node.attributes) do
              node.children.each { |child| emitter.emit_node(syntax, child) }
              nil
            end
          else
            syntax.node(node.name, node.attributes)
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
        Tree.print options, &@source_code
      end

      def render(options)
        Tree.render options, &@source_code
      end

      def evaluate(options)
        Tree.evaluate options, &@source_code
      end

      def build
        Tree.build(&@source_code)
      end
    end

    def self.source(&source_code)
      Source.new(&source_code)
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
      builder = Builder.new
      # printer = Language::External::ParseTree::Printer.new
      language = options[:from]
      syntax = @syntax[language]
      # errors = syntax.parse(text: options[:text], visitor: printer, ignore_actions: true)
      errors = syntax.parse(text: options[:text], visitor: builder)
      [builder.root, errors]
      # [nil, errors]
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

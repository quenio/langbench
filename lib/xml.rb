require 'visitor'
require 'language'
require 'text'

module XML

  module External

    class Syntax

      def initialize
        @skip = /\s*/

        @tokens = { name: /[A-Za-z0-9]+/ }

        @grammar = {
          start: :element,
          element: %i[open close],
          open: %w['<' :id '>'],
          close: %w['</' :id '>']
        }
      end

      def parse(text, &action)
        tokenizer = Text::Tokenizer.new(skip: @skip, tokens: @tokens)
        parser = Language::Parser.new(grammar: @grammar)
        parser.parse(tokenizer.tokenize(text), &action)
      end

    end

  end

  module Template

    def open_markup(name, attributes)
      "<#{name}#{attributes_list(attributes)}>"
    end

    def close_markup(name)
      "</#{name}>"
    end

    def inner_content(value)
      value.to_s
    end

    def attributes_list(attributes)
      result = attributes.map { |attrib| "#{attrib[0]}=\"#{attrib[1]}\"" }.join(' ')
      result = ' ' + result unless result.empty?
      result
    end

  end

  class Printer

    include Visitor
    include Template
    include Text::Printer

    def initialize
      init_indentation
    end

    def visit_content(value)
      print inner_content(value)
      inline
    end

    def enter_node(name, attributes, &block)
      enter_section
      indent_print open_markup(name, attributes)
      if block
        indent
      else
        inline
      end
    end

    def exit_node(name, _attributes, &block)
      unindent if block
      indent_print close_markup(name)
      exit_section
    end

  end

  class Renderer < Printer

    include Text::Renderer

    def initialize
      super
      init_text_rendering
    end
  end

end
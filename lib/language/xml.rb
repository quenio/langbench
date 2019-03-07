require 'language'

module MPF

  module XML

    class Syntax < Language::External::Syntax

      tokens etag_open: '</'

      grammar start: %i[sp? element sp?],
              element: %i[stag content* etag],
              stag: ['<', :name, :'attribute*', :sp?, '>'],
              etag: [:etag_open, :name, '>'],
              attribute: [:sp, :name, :sp?, '=', :sp?, :value],
              content: { any: %i[element data] },
              name: /[A-Za-z][A-Za-z0-9]*/,
              value: { regex: /"[^"<&]*"/, firsts: /"/ },
              data: /[^<&]+/,
              sp: /\s+/

      before :stag do
        @attributes = {}
      end

      after :attribute do |attributes|
        if attributes.any?
          raise "Expected name but found: #{attributes}" unless attributes[:name]
          raise "Expected value but found: #{attributes}" unless attributes[:value]

          name = attributes[:name]
          value = attributes[:value][1..-2]
          @attributes = @attributes.merge(name => value)
        end
      end

      after :stag do |attributes, visitor|
        visitor.enter_node(attributes[:name], @attributes)
      end

      after :etag do |attributes, visitor|
        visitor.exit_node(attributes[:name])
      end

      after :content do |attributes, visitor|
        visitor.visit_content(attributes[:data]) if attributes.any? and attributes[:data]
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
      include Text::Printer
      include Template

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

end


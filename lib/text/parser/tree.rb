require 'text'
require 'lang/meta'

module Text::Parser::Tree

  module Template

    def opened_node(name, attributes)
      "#{name}{#{attributes_list(attributes)}}"
    end

    def closed_node(name, attributes)
      "/#{name}{#{attributes_list(attributes)}}"
    end

    def inner_content(value)
      value.to_s
    end

    def attributes_list(attributes)
      result = attributes.map { |attrib| "#{attrib[0]}=#{attrib[1].inspect}" }.join(', ')
      result = ' ' + result + ' ' unless result.empty?
      result
    end

  end

  class Printer

    include Meta::Visitor
    include Template
    include Text::Printer

    def initialize
      init_indentation
    end

    def enter_node(name, attributes = {})
      enter_section
      indent_print opened_node(name, attributes)
      indent
    end

    def exit_node(name, attributes = {})
      unindent
      indent_print closed_node(name, attributes)
      exit_section
    end

  end

end

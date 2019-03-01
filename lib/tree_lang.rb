require 'visitor'
require 'xml_template'
require 'pretty_printer'

module TreeLang

  class Structure

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

  end

  class XmlPrinter

    include Visitor
    include XmlTemplate
    include PrettyPrinter

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

  @printer = { xml: XmlPrinter }

  def self.print(options = {}, &block)
    format = options[:to]
    printer = @printer[format].new
    Structure.new(visitor: printer).instance_eval &block
  end

end


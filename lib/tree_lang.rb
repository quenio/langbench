require 'visitor'
require 'xml_template'
require 'pretty_printer'
require 'text_renderer'

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

  def self.print(options = {}, &source_code)
    format = options[:to]
    visit(visitor: @printer[format].new, &source_code)
  end

  class XmlRenderer < XmlPrinter

    include TextRenderer

    def initialize
      super
      init_rendering
    end
  end

  @renderer = { xml: XmlRenderer }

  def self.render(options = {}, &source_code)
    format = options[:to]
    renderer = @renderer[format].new
    visit(visitor: renderer, &source_code)
    renderer.text
  end

  def self.visit(options = {}, &source_code)
    Structure.new(visitor: options[:visitor]).instance_eval &source_code
  end

end


# struct_lang.rb

module TreeLang

  module Structure

    def node(name, attributes = {}, &block)
      emit_node(name, attributes, &block)
      nil
    end

    def content(value)
      emit_content(value)
      nil
    end

    private

    def emit_node(name, attributes = {}, &block)
      enter_node(name, attributes, &block)
      emit_children(&block) if block
      exit_node(name, attributes, &block)
    end

    def enter_node(_name, _attributes, &_block)
      raise 'Not implemented.'
    end

    def exit_node(_name, _attributes, &_block)
      raise 'Not implemented.'
    end

    def emit_children
      value = yield
      emit_content(value) if value
    end

    def emit_content(_value)
      raise 'Not implemented.'
    end

  end

  module PrettyPrinter

    def init_indentation
      @indent = ''
      @indent_next = true
      @line_changed = [false]
    end

    def indent_print(value)
      print @indent_next ? "\n#{@indent}#{value}" : value
    end

    def indent
      @indent += '  '
    end

    def unindent
      @indent.chomp!('  ')
    end

    def inline
      @indent_next = false
    end

    def enter_section
      @line_changed.push(@indent_next)
    end

    def exit_section
      if @indent_next
        @line_changed.pop
      else
        @indent_next = @line_changed.pop
      end
    end

  end

  class XmlPrinter

    include Structure
    include PrettyPrinter

    private

    def initialize
      init_indentation
    end

    def emit_content(value)
      print value
      inline
    end

    def enter_node(name, attributes, &block)
      enter_section
      indent_print "<#{name}#{attrib_text(attributes)}>"
      if block
        indent
      else
        inline
      end
    end

    def attrib_text(attributes)
      result = attributes.map { |attrib| "#{attrib[0]}=\"#{attrib[1]}\"" }.join(' ')
      result = ' ' + result unless result.empty?
      result
    end

    def exit_node(name, _attributes, &block)
      unindent if block
      indent_print "</#{name}>"
      exit_section
    end

  end

  @printer = { xml: XmlPrinter }

  def self.print(options = {}, &block)
    format = options[:to]
    @printer[format].new.instance_eval &block
  end

end


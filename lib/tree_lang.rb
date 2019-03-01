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

  class XmlPrinter

    include Structure

    def initialize
      @indent = ''
      @indent_next = true
      @line_changed = [false]
    end

    private

    def emit_content(value)
      print value
      @indent_next = false
    end

    def enter_node(name, attributes, &block)
      if @indent_next
        print "\n#{@indent}<#{name}"
      else
        print "<#{name}"
      end
      @line_changed.push(@indent_next)
      attributes.each { |attrib| print " #{attrib[0]}=\"#{attrib[1]}\"" }
      print '>'
      if block
        @indent += '  '
      else
        @indent_next = false
      end
    end

    def exit_node(name, _attributes, &block)
      @indent.chomp!('  ') if block
      if @indent_next
        print "\n#{@indent}</#{name}>"
        @line_changed.pop
      else
        print "</#{name}>"
        @indent_next = @line_changed.pop
      end
    end

  end

  @printer = { xml: XmlPrinter }

  def self.print(options = {}, &block)
    format = options[:to]
    @printer[format].new.instance_eval &block
  end

end


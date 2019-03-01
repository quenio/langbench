# struct_lang.rb

module TreeLang

  class XmlPrinter

    def initialize
      @indent = ''
    end

    def node(name, attributes = {}, &block)
      enter_node(name, attributes)
      yield_children(&block)
      exit_node(name)
      nil
    end

    def content(value)
      print value
      @indent_next = false
      nil
    end

    private

    def enter_node(name, attributes)
      print "\n#{@indent}<#{name}"
      attributes.each { |attrib| print " #{attrib[0]}=\"#{attrib[1]}\"" }
      print '>'
    end

    def exit_node(name)
      if @indent_next
        print "\n#{@indent}</#{name}>"
      else
        print "</#{name}>"
        @indent_next = true
      end
    end

    def yield_children(&block)
      if block
        @indent += '  '
        value = yield
        content(value) if value
        @indent.chomp!('  ')
      else
        @indent_next = false
      end
    end

  end

  @printer = { xml: XmlPrinter }

  def self.print(options = {}, &block)
    format = options[:to]
    @printer[format].new.instance_eval &block
  end

end


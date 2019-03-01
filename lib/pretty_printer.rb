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

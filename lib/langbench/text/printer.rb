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

module Text::Printer

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

  def new_line
    @indent_next = true
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

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

require 'lang_bench/test'

class ModuleTest < Test
  def navigation_tree
    LangBench::Tree.source do
      node(:navigation) do
        node(:item, title: 'Bills')
        node(:item, title: 'Installments')
        node(:item, title: 'Expenses')
        node(:item, title: 'Groceries')
      end
    end
  end

  def xml_text
    <<~XML.strip
      <navigation>
        <item title="Bills"></item>
        <item title="Installments"></item>
        <item title="Expenses"></item>
        <item title="Groceries"></item>
      </navigation>
    XML
  end

  def test_renders_xml
    assert_equal xml_text, navigation_tree.render(to: :xml).strip
  end
end


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

class TreeTest < Test
  Tree = LangBench::Tree
  Printer = LangBench::XML::Printer

  def source
    Tree.source do
      node(:html, lang: 'en') do
        node(:head) do
          node(:title) { content('Good ') || node(:b) { 'Books' } }
        end
        node(:body) do
          node(:div, class: 'header') { node(:img, src: 'logo.png', alt: 'Books Logo') }
        end
      end
    end
  end

  def xml_text
    "\n" + <<~XML.strip
      <html lang="en">
        <head>
          <title>Good <b>Books</b></title>
        </head>
        <body>
          <div class="header">
            <img src="logo.png" alt="Books Logo"></img>
          </div>
        </body>
      </html>
    XML
  end

  def test_print
    printed_text = +''
    Spy.on_instance_method(Printer, :print).and_return do |text|
      printed_text << text
    end
    source.print(to: :xml)
    assert_equal xml_text, printed_text
  ensure
    Spy.off_instance_method(Printer, :print)
  end

  def test_build_emit_render
    assert_equal xml_text, Tree.emit(from: source.build).render(to: :xml)
  end

  def test_parse_emit_render
    model, _errors = Tree.parse(from: :xml, text: xml_text)
    assert_equal xml_text, Tree.emit(from: model).render(to: :xml)
  end
end

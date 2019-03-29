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

require 'mpf/tree'

module MPF

  source_code = Tree.source do
    node(:html, lang: 'en') do
      node(:head) do
        node(:title) do
          content 'Good '
          node(:b) { 'Books' }
        end
      end
      node(:body) do
        node(:div, class: 'header') do
          node(:img, src: 'logo.png', alt: 'Books Logo')
        end
      end
    end
  end

  source_code.print(to: :xml)
  print "\n\n"

  model = source_code.build
  print model.inspect
  print "\n\n"

  source_code = Tree.emit(from: model)
  source_code.print(to: :xml)
  print "\n\n"

  target_code = source_code.render(to: :xml)
  print target_code
  print "\n\n"

  print">>> Parsing from XML:\n"
  model, errors = Tree.parse(from: :xml, text: target_code)
  if errors.empty?
    Tree.emit(from: model).print(to: :xml)
  else
    errors.each { |error| print "\nError: #{error}" }
  end
  print "\n\n"

  RSpec.describe Tree do
    # it 'translates the layout elements to a div' do
    #   # expected_target = '<div class="container"></div>'
    #   # actual_target = StructLang.translate source: given_source, to: :xml
    #   # expect(actual_target).to eq(expected_target)
    # end
  end

end
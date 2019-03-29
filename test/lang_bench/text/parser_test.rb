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

class ParserTest < Test
  def tokens
    {
      etag_open: '</'
    }
  end

  def grammar
    {
      element: %i[stag content? etag],
      stag: ['<', :name, '>'],
      etag: [:etag_open, :name, '>'],
      content: [{ any: %i[data_regex number element*] }],
      name: /[A-Za-z][A-Za-z0-9]*/,
      number: { regex: /[0-9]+/ },
      data_regex: { regex: /[A-Za-z][A-Za-z0-9]*/, firsts: /[A-Za-z]/ }
    }
  end

  def parse(params)
    parser = LangBench::Text::Parser.new(
      tokenizer: LangBench::Text::Tokenizer.new(skip: /\s+/, rules: tokens),
      grammar: grammar
    )
    errors = parser.parse(params[:given])
    assert_equal params[:expected], errors
  end

  def test_valid_sentences
    sentences = %w[
      <html></html> <div>abc</div> <html>123</html> <html><body></body></html>
      <html><body><header></header><footer></footer></body></html>
    ]
    sentences.each do |text|
      parse(given: text, expected: [])
    end
  end

  def test_invalid_sentence_with_multiple_numbers
    parse(
      given: '<html><body>123 456</body></html>',
      expected: [
        { missing: :etag_open, found: { char: '4' } },
        { missing: :name, found: { char: '4' } },
        { missing: '>', found: { char: '4' } }
      ]
    )
  end

  def test_invalid_sentence_missing_initial_character
    parse(
      given: 'html></html>',
      expected: [{ missing: '<', found: { char: 'h' } }]
    )
  end

  def test_invalid_sentence_missing_final_character
    parse(
      given: '<html></html',
      expected: [{ missing: '>' }]
    )
  end

  def test_invalid_sentence_with_an_extra_character
    parse(
      given: '<html></html>>',
      expected: [{ unrecognized: '>' }]
    )
  end
end

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

class TokenizerTest < Test
  Token = LangBench::Text::Token
  Tokenizer = LangBench::Text::Tokenizer

  def test_skipping
    tokenizer = Tokenizer.new(skip: /\d*/)
    source = +'234token'
    tokenizer.skip!(source)
    assert_equal 'token', source
  end

  def test_next_token_with_single_rule
    tokenizer = Tokenizer.new(rules: { id: /[a-z]+/ })
    source = 'token'
    token = tokenizer.next_token(source)
    assert_equal 'token', source
    assert_equal Token.new(id: 'token'), token
  end

  def test_next_with_two_rules
    tokenizer = Tokenizer.new(rules: { id: /[a-z]+/, number: /[0-9]+/ })
    source = +'token1234'

    token = tokenizer.next!(source)
    assert_equal '1234', source
    assert_equal Token.new(id: 'token'), token

    token = tokenizer.next!(source)
    assert_equal '', source
    assert_equal Token.new(number: '1234'), token
  end

  def test_next_if_not_initial_match
    tokenizer = Tokenizer.new(rules: { id: /[a-z]+/, number: /[0-9]+/ })
    source = +'  token1234'

    token = tokenizer.next!(source)
    assert_equal ' token1234', source
    assert_equal Token.new(char: ' '), token
  end

  def test_tokenize_all_tokens
    tokenizer = Tokenizer.new(
      skip: /\s*/,
      rules: { id: /[a-z]+/, number: /[0-9]+/ }
    )
    source = '  1234  <token>   '
    actual_tokens = tokenizer.tokenize(source)
    expected_tokens = [{ number: '1234' }, { char: '<' }, { id: 'token' }, { char: '>' }]
    assert_equal '  1234  <token>   ', source
    assert_equal expected_tokens.map(&Token.method(:new)), actual_tokens
  end
end

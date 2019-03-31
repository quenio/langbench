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

class PredicateTest < Test
  Predicate = LangBench::Logic::Predicate
  Symbol = LangBench::Logic::Symbol
  Term = LangBench::Logic::Term

  def test_symbol_presence
    predicate = Predicate.new(terms: [Term.new]) # missing symbol
    assert predicate.invalid?
    assert predicate.errors.added? :symbol, :blank
  end

  def test_symbol_type
    predicate = Predicate.new(symbol: 'not a symbol')
    assert predicate.invalid?
    assert predicate.errors.added? :symbol, :type, with: Symbol
  end

  def test_terms_presence
    predicate = Predicate.new(symbol: Symbol.new) # missing terms
    assert predicate.invalid?
    assert predicate.errors.added? :terms, :blank
  end

  def test_terms_enumerable
    predicate = Predicate.new(symbol: Symbol.new, terms: 'not enumerable')
    assert predicate.invalid?
    assert predicate.errors.added? :terms, :item_type, with: Term
  end

  def test_terms_item_type
    predicate = Predicate.new(symbol: Symbol.new, terms: [Term.new, 'not term'])
    assert predicate.invalid?
    assert predicate.errors.added? :terms, :item_type, with: Term
  end

  def test_empty
    predicate = Predicate.new
    assert predicate.invalid?
    assert_equal 4, predicate.errors.size
  end

  def test_valid
    predicate = Predicate.new(symbol: Symbol.new, terms: [Term.new])
    assert predicate.valid?
    assert predicate.errors.empty?
  end
end

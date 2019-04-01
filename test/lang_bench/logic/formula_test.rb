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

class FormulaTest < Test
  Formula = LangBench::Logic::Formula
  Quantifier = LangBench::Logic::Quantifier
  Term = LangBench::Logic::Term

  def test_quantifier_type
    formula = Formula.new(quantifier: 'not a quantifier', term: Term.new)
    assert formula.invalid?
    assert formula.errors.added? :quantifier, :type, with: Quantifier
  end

  def test_term_presence
    formula = Formula.new(quantifier: Quantifier.new) # missing term
    assert formula.invalid?
    assert formula.errors.added? :term, :blank
  end

  def test_term_type
    formula = Formula.new(quantifier: Quantifier.new, term: 'a')
    assert formula.invalid?
    assert formula.errors.added? :term, :type, with: Term
  end

  def test_empty
    formula = Formula.new
    assert formula.invalid?
    assert_equal 3, formula.errors.size
  end

  def test_valid
    formula = Formula.new(quantifier: Quantifier.new, term: Term.new)
    assert formula.valid?
    assert formula.errors.empty?
  end
end

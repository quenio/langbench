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

class PropositionLogicTest < Test
  def interpret(params)
    errors, value = LangBench::Proposition.interpret(params)
    assert_empty errors
    if params[:value].nil?
      assert value
    else
      assert_equal params[:value], value
    end
  end

  def test_literal
    [['false', false], ['true', true]].each do |text, value|
      interpret(text: text, value: value)
    end
  end

  def test_variable
    [false, true].each do |value|
      interpret(text: 'lights_on', interpretation: { lights_on: value }, value: value)
    end
  end

  def test_not
    [false, true].each do |value|
      interpret(text: 'not lights_on', interpretation: { lights_on: value }, value: (not value))
    end
  end

  def test_and
    cases = [[true, false, false], [false, true, false], [false, false, false], [true, true, true]]
    cases.each do |lights_on, doors_closed, value|
      interpret(
        text: 'doors_closed and lights_on',
        interpretation: { lights_on: lights_on, doors_closed: doors_closed },
        value: value
      )
    end
  end

  def test_or
    cases = [[true, true, true], [false, true, true], [true, false, true], [false, false, false]]
    cases.each do |lights_on, doors_closed, value|
      interpret(
        text: 'doors_closed or lights_on',
        interpretation: { lights_on: lights_on, doors_closed: doors_closed },
        value: value
      )
    end
  end

  def test_if
    cases = [[true, false, false], [true, true, true], [false, true, true], [false, false, true]]
    cases.each do |lights_on, doors_closed, value|
      interpret(
        text: 'doors_closed if lights_on',
        interpretation: { lights_on: lights_on, doors_closed: doors_closed },
        value: value
      )
    end
  end

  def test_iif
    cases = [[true, true, true], [false, false, true], [false, true, false], [true, false, false]]
    cases.each do |lights_on, doors_closed, value|
      interpret(
        text: 'doors_closed iif lights_on',
        interpretation: { lights_on: lights_on, doors_closed: doors_closed },
        value: value
      )
    end
  end

  def test_compound_or
    interpret(
      text: 'doors_closed and lights_on or false',
      interpretation: { lights_on: true, doors_closed: true }
    )
  end

  def test_compound_and
    interpret(
      text: 'doors_closed and lights_on and false',
      interpretation: { lights_on: true, doors_closed: true },
      value: false
    )
  end
end

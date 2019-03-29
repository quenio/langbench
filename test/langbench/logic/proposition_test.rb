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

RSpec.describe Logic::Proposition do

  def interpret(params)
    errors, value = Logic::Proposition.interpret(params)
    expect(errors).to eq([])
    if params[:value].nil?
      expect(value).to eq(true)
    else
      expect(value).to eq(params[:value])
    end
  end

  describe '#interpret' do

    describe 'literal' do

      it 'is true' do
        interpret(text: 'true')
      end

      it 'is false' do
        interpret(text: 'false', value: false)
      end

    end

    describe 'variable' do

      it 'is true' do
        interpret(text: 'lights_on', interpretation: { lights_on: true })
      end

      it 'is false' do
        interpret(text: 'lights_on', interpretation: { lights_on: false }, value: false)
      end

    end

    describe '"not" proposition' do

      it 'is true' do
        interpret(text: 'not lights_on', interpretation: { lights_on: false })
      end

      it 'is false' do
        interpret(text: 'not lights_on', interpretation: { lights_on: true }, value: false)
      end

    end

    describe '"and" proposition' do

      it 'is true' do
        interpret(
          text: 'doors_closed and lights_on',
          interpretation: { lights_on: true, doors_closed: true }
        )
      end

      it 'is false' do
        [[true, false], [false, true], [false, false]].each do |lights_on, doors_closed|
          interpret(
            text: 'doors_closed and lights_on',
            interpretation: { lights_on: lights_on, doors_closed: doors_closed },
            value: false
          )
        end
      end

    end

    describe '"or" proposition' do

      it 'is true' do
        [[true, true], [true, false], [false, true]].each do |lights_on, doors_closed|
          interpret(
            text: 'doors_closed or lights_on',
            interpretation: { lights_on: lights_on, doors_closed: doors_closed }
          )
        end
      end

      it 'is false' do
        interpret(
          text: 'doors_closed or lights_on',
          interpretation: { lights_on: false, doors_closed: false },
          value: false
        )
      end

    end

    describe '"if" proposition' do

      it 'is true' do
        [[true, true], [false, true], [false, false]].each do |lights_on, doors_closed|
          interpret(
            text: 'doors_closed if lights_on',
            interpretation: { lights_on: lights_on, doors_closed: doors_closed }
          )
        end
      end

      it 'is false' do
        interpret(
          text: 'doors_closed if lights_on',
          interpretation: { lights_on: true, doors_closed: false },
          value: false
        )
      end

    end

    describe '"iif" proposition' do

      it 'is true' do
        [[true, true], [false, false]].each do |lights_on, doors_closed|
          interpret(
            text: 'doors_closed iif lights_on',
            interpretation: { lights_on: lights_on, doors_closed: doors_closed }
          )
        end
      end

      it 'is false' do
        [[true, false], [false, true]].each do |lights_on, doors_closed|
          interpret(
            text: 'doors_closed iif lights_on',
            interpretation: { lights_on: lights_on, doors_closed: doors_closed },
            value: false
          )
        end
      end

    end

    describe 'compound proposition' do

      it 'is true' do
        interpret(
          text: 'doors_closed and lights_on or false',
          interpretation: { lights_on: true, doors_closed: true }
        )
      end

      it 'is false' do
        interpret(
          text: 'doors_closed and lights_on and false',
          interpretation: { lights_on: true, doors_closed: true },
          value: false
        )
      end

    end

  end

  describe '#sentence' do

    describe '#satisfied_by' do

      it 'compound proposition' do
        expect(
          Logic::Proposition.sentence('doors_closed and lights_on').satisfied_by?(
            lights_on: true,
            doors_closed: true
          )
        ).to eq(true)
      end

    end

  end

end

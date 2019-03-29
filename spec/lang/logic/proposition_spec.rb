require 'lang/logic/proposition'

RSpec.describe Lang::Logic::Proposition do

  include Lang::Logic::Proposition

  def interpret(params)
    errors, value = interpret(params)
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
          Propositional.sentence('doors_closed and lights_on').satisfied_by?(
            lights_on: true,
            doors_closed: true
          )
        ).to eq(true)
      end

    end

  end

end

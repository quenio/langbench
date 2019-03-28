require 'mpf/external/logic/propositional'

module MPF::External::Logic

  RSpec.describe Propositional do

    def interpret(params)
      errors, value = Propositional.interpret(params)
      expect(errors).to eq([])
      if params[:value].nil?
        expect(value).to eq(true)
      else
        expect(value).to eq(params[:value])
      end
    end

    describe '#interpret' do

      it 'literal: "true"' do
        interpret(text: 'true')
      end

      it 'literal: "false"' do
        interpret(text: 'false', value: false)
      end

      it 'variable' do
        interpret(text: 'lights_on', interpretation: { lights_on: true })
      end

      it 'unary proposition' do
        interpret(text: 'not lights_on', interpretation: { lights_on: false })
      end

      it 'binary proposition' do
        interpret(
          text: 'doors_closed and lights_on',
          interpretation: { lights_on: true, doors_closed: true }
        )
      end

      it 'compound proposition' do
        interpret(
          text: 'doors_closed and lights_on or false',
          interpretation: { lights_on: true, doors_closed: true }
        )
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

end

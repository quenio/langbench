require 'mpf/external/logic/predicate'

module MPF::External::Logic

  RSpec.describe Predicate do

    def interpret(params)
      errors, value = Predicate.interpret(params)
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

    end

  end

end
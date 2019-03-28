require 'mpf/external/logic/propositional'

RSpec.describe MPF::External::Logic::Propositional do

  def interpret(params)
    errors, value = MPF::External::Logic::Propositional.interpret(params)
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

end

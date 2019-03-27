require 'mpf/external/parse_tree'
require 'mpf/external/logic/propositional'

module MPF::External::Logic::Propositional

  RSpec.describe Syntax do

    def parses(text)
      printer = MPF::External::ParseTree::Printer.new
      errors = Syntax.new.parse(text: text, visitor: printer, ignore_actions: true)
      expect(errors).to eq([])
    end

    describe '#parse' do

      it 'recognizes literal: "true"' do
        parses('true')
      end

      it 'recognizes literal: "false"' do
        parses('false')
      end

      it 'recognizes a variable' do
        parses('lights_on')
      end

      it 'recognizes a unary proposition' do
        parses('not lights_on')
      end

      it 'recognizes a binary proposition' do
        parses('doors_closed and lights_on')
      end

      it 'recognizes a compound proposition' do
        parses('doors_closed and lights_on or false')
      end

    end

  end

end

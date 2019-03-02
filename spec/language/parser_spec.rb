require 'language'

RSpec.describe Language::Parser do

  before do
    @grammars = property_of do
      [
        sized(5) { string(:alpha) }.to_sym,
        sized(1) { string(:punct) },
        sized(5) { string(:alnum) },
        sized(1) { string(:punct) }
      ]
    end
  end

  def check
    @grammars.check do |element, start_char, id, end_char|
      rules = {
        element => %i[part1 part2],
        part1: [start_char, :id],
        part2: [end_char]
      }
      @parser = Language::Parser.new(grammar: rules)
      options = yield start_char, id, end_char
      errors = @parser.parse(options[:given])
      expect(errors).to eq(options[:expected])
    end
  end

  describe '#parse' do

    it 'recognizes a valid sentence' do
      check do |start_ch, id, end_ch|
        {
          given: [{ char: start_ch }, { id: id }, { char: end_ch }],
          expected: []
        }
      end
    end

    it 'does not recognize a sentence missing initial character' do
      check do |start_ch, id, end_ch|
        {
          given: [{ id: id }, { char: end_ch }],
          expected: [{ missing: start_ch }]
        }
      end
    end

    it 'does not recognize a sentence missing final character' do
      check do |start_ch, id, end_ch|
        {
          given: [{ char: start_ch }, { id: id }],
          expected: [{ missing: end_ch }]
        }
      end
    end

    it 'does not recognize a sentence with an extra character' do
      check do |start_ch, id, end_ch|
        {
          given: [{ char: start_ch }, { id: id }, { char: end_ch }, { char: end_ch }],
          expected: [{ unrecognized: end_ch }]
        }
      end
    end

  end

end

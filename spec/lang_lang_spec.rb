require 'rantly'
require 'rantly/rspec_extensions'

RSpec.describe LangLang::Tokenizer do

  it 'skips digits' do
    tokenizer = LangLang::Tokenizer.new(skip: /\d*/)
    source = '234token'

    tokenizer.skip!(source)

    expect(source).to eq('token')
  end

  it 'finds next token with given single rule' do
    tokenizer = LangLang::Tokenizer.new(rules: { id: /[a-z]+/ })
    source = 'token'

    token = tokenizer.next_token(source)

    expect(source).to eq('token')
    expect(token).to eq(id: 'token')
  end

  it 'finds next token with given two rules' do
    tokenizer = LangLang::Tokenizer.new(rules: { id: /[a-z]+/, number: /[0-9]+/ })
    source = 'token1234'

    tokens = tokenizer.next!(source)
    expect(source).to eq('1234')
    expect(tokens).to eq(id: 'token')

    tokens = tokenizer.next!(source)
    expect(source).to eq('')
    expect(tokens).to eq(number: '1234')
  end

  it 'does not find next token if not initial match' do
    tokenizer = LangLang::Tokenizer.new(rules: { id: /[a-z]+/, number: /[0-9]+/ })
    source = '  token1234'

    tokens = tokenizer.next!(source)
    expect(source).to eq(' token1234')
    expect(tokens).to eq(char: ' ')
  end

  it 'finds all tokens' do
    tokenizer = LangLang::Tokenizer.new(skip: /\s*/, rules: { id: /[a-z]+/, number: /[0-9]+/ })
    source = '  1234  <token>   '

    tokens = tokenizer.tokenize(source)

    expect(source).to eq('  1234  <token>   ')
    expect(tokens).to eq([{ number: '1234' }, { char: '<' }, { id: 'token' }, { char: '>' }])
  end

end

RSpec.describe LangLang::Parser do

  before do
    @grammars = property_of do
      [
        sized(1) { string(:punct) },
        sized(5) { string(:alnum) },
        sized(1) { string(:punct) }
      ]
    end
  end

  def check
    @grammars.check do |start_char, id, end_char|
      @parser = LangLang::Parser.new(grammar: { element: [start_char, id, end_char] })
      options = yield start_char, id, end_char
      errors = @parser.recognize(options[:given])
      expect(errors).to eq(options[:expected])
    end
  end

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

end

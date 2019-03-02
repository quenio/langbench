require 'text'

module MPF

  RSpec.describe Text::Tokenizer do

    it 'skips digits' do
      tokenizer = Text::Tokenizer.new(skip: /\d*/)
      source = '234token'

      tokenizer.skip!(source)

      expect(source).to eq('token')
    end

    it 'finds next token with given single rule' do
      tokenizer = Text::Tokenizer.new(rules: { id: /[a-z]+/ })
      source = 'token'

      token = tokenizer.next_token(source)

      expect(source).to eq('token')
      expect(token).to eq(id: 'token')
    end

    it 'finds next token with given two rules' do
      tokenizer = Text::Tokenizer.new(rules: { id: /[a-z]+/, number: /[0-9]+/ })
      source = 'token1234'

      tokens = tokenizer.next!(source)
      expect(source).to eq('1234')
      expect(tokens).to eq(id: 'token')

      tokens = tokenizer.next!(source)
      expect(source).to eq('')
      expect(tokens).to eq(number: '1234')
    end

    it 'does not find next token if not initial match' do
      tokenizer = Text::Tokenizer.new(rules: { id: /[a-z]+/, number: /[0-9]+/ })
      source = '  token1234'

      tokens = tokenizer.next!(source)
      expect(source).to eq(' token1234')
      expect(tokens).to eq(char: ' ')
    end

    it 'finds all tokens' do
      tokenizer = Text::Tokenizer.new(skip: /\s*/, rules: { id: /[a-z]+/, number: /[0-9]+/ })
      source = '  1234  <token>   '

      tokens = tokenizer.tokenize(source)

      expect(source).to eq('  1234  <token>   ')
      expect(tokens).to eq([{ number: '1234' }, { char: '<' }, { id: 'token' }, { char: '>' }])
    end

  end

end

require 'mpf/external/text'

module MPF

  module External

    module Text

      RSpec.describe Tokenizer do

        describe 'skip!' do

          it 'skips digits' do
            tokenizer = Tokenizer.new(skip: /\d*/)
            source = '234token'

            tokenizer.skip!(source)

            expect(source).to eq('token')
          end

        end

        describe 'next_token' do

          it 'finds next token with given single rule' do
            tokenizer = Tokenizer.new(rules: { id: /[a-z]+/ })
            source = 'token'

            token = tokenizer.next_token(source)

            expect(source).to eq('token')
            expect(token).to eq(Token.new(id: 'token'))
          end

        end

        describe 'next!' do

          it 'finds next token with given two rules' do
            tokenizer = Text::Tokenizer.new(rules: { id: /[a-z]+/, number: /[0-9]+/ })
            source = 'token1234'

            tokens = tokenizer.next!(source)
            expect(source).to eq('1234')
            expect(tokens).to eq(Token.new(id: 'token'))

            tokens = tokenizer.next!(source)
            expect(source).to eq('')
            expect(tokens).to eq(Token.new(number: '1234'))
          end

          it 'does not find next token if not initial match' do
            tokenizer = Text::Tokenizer.new(rules: { id: /[a-z]+/, number: /[0-9]+/ })
            source = '  token1234'

            tokens = tokenizer.next!(source)
            expect(source).to eq(' token1234')
            expect(tokens).to eq(Token.new(char: ' '))
          end

        end

        describe 'tokenize' do

          it 'finds all tokens' do
            tokenizer = Text::Tokenizer.new(
              skip: /\s*/,
              rules: { id: /[a-z]+/, number: /[0-9]+/ }
            )
            source = '  1234  <token>   '

            tokens = tokenizer.tokenize(source)

            expect(source).to eq('  1234  <token>   ')
            expect(tokens).to eq(
                                [
                                  Token.new(number: '1234'),
                                  Token.new(char: '<'),
                                  Token.new(id: 'token'),
                                  Token.new(char: '>')
                                ]
                              )
          end

        end

      end

    end

  end

end

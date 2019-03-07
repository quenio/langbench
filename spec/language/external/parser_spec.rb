require 'mpf/external/parser'

module MPF

  module External

    RSpec.describe Parser do

      def check
        tokens = {
          etag_open: '</'
        }
        grammar = {
          element: %i[stag content? etag],
          stag: ['<', :name, '>'],
          etag: [:etag_open, :name, '>'],
          content: [{ any: %i[data_regex number element*] }],
          name: /[A-Za-z][A-Za-z0-9]*/,
          number: { regex: /[0-9]+/ },
          data_regex: { regex: /[A-Za-z][A-Za-z0-9]*/, firsts: /[A-Za-z]/ }
        }
        @parser = Parser.new(
          tokenizer: Text::Tokenizer.new(skip: /\s+/, rules: tokens),
          grammar: grammar
        )
        options = yield
        errors = @parser.parse(options[:given])
        expect(errors).to eq(options[:expected])
      end

      describe '#parse' do

        it 'recognizes a valid sentence matching the regex for name' do
          check do
            {
              given: '<div>abc</div>',
              expected: []
            }
          end
        end

        it 'recognizes a valid sentence without optional' do
          check do
            {
              given: '<html></html>',
              expected: []
            }
          end
        end

        it 'recognizes a valid sentence with optional' do
          check do
            {
              given: '<html>text</html>',
              expected: []
            }
          end
        end

        it 'recognizes a valid sentence with alternative number' do
          check do
            {
              given: '<html>123</html>',
              expected: []
            }
          end
        end

        it 'recognizes a valid sentence with alternative non-terminal' do
          check do
            {
              given: '<html><body></body></html>',
              expected: []
            }
          end
        end

        it 'recognizes a valid sentence with multiple terms' do
          check do
            {
              given: '<html><body><header></header><footer></footer></body></html>',
              expected: []
            }
          end
        end

        it 'does not recognizes a sentence with multiple numbers' do
          check do
            {
              given: '<html><body>123 456</body></html>',
              expected: [
                { missing: :etag_open, found: { char: '4' } },
                { missing: :name, found: { char: '4' } },
                { missing: '>', found: { char: '4' } }
              ]
            }
          end
        end

        it 'does not recognize a sentence missing initial character' do
          check do
            {
              given: 'html></html>',
              expected: [{ missing: '<', found: { char: 'h' } }]
            }
          end
        end

        it 'does not recognize a sentence missing final character' do
          check do
            {
              given: '<html></html',
              expected: [{ missing: '>' }]
            }
          end
        end

        it 'does not recognize a sentence with an extra character' do
          check do
            {
              given: '<html></html>>',
              expected: [{ unrecognized: '>' }]
            }
          end
        end

      end

    end

  end

end

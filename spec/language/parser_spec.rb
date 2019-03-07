require 'parser'

module MPF

  RSpec.describe Parser do

    def check
      rules = {
        element: %i[stag content? etag],
        stag: ['<', { any: %i[name name_regex] }, '>'],
        etag: [:etag_open, { any: %i[name name_regex] }, '>'],
        content: [{ any: %i[data_regex number element*] }],
        name_regex: /[A-Za-z][A-Za-z0-9]*/,
        data_regex: { regex: /[A-Za-z][A-Za-z0-9]*/, firsts: /[A-Za-z]/ }
      }
      @parser = Parser.new(grammar: rules)
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
            given: [
              { char: '<' }, { name: 'html' }, { char: '>' },
              { etag_open: '</' }, { name: 'html' }, { char: '>' }
            ],
            expected: []
          }
        end
      end

      it 'recognizes a valid sentence without optional' do
        check do
          {
            given: [
              { char: '<' }, { name: 'html' }, { char: '>' },
              { etag_open: '</' }, { name: 'html' }, { char: '>' }
            ],
            expected: []
          }
        end
      end

      it 'recognizes a valid sentence with optional' do
        check do
          {
            given: [
              { char: '<' }, { name: 'html' }, { char: '>' },
              { char: 't' }, { char: 'e' }, { char: 'x' }, { char: 't' },
              { etag_open: '</' }, { name: 'html' }, { char: '>' }
            ],
            expected: []
          }
        end
      end

      it 'recognizes a valid sentence with alternative number' do
        check do
          {
            given: [
              { char: '<' }, { name: 'html' }, { char: '>' },
              { number: 123 },
              { etag_open: '</' }, { name: 'html' }, { char: '>' }
            ],
            expected: []
          }
        end
      end

      it 'recognizes a valid sentence with alternative non-terminal' do
        check do
          {
            given: [
              { char: '<' }, { name: 'html' }, { char: '>' },
              { char: '<' }, { name: 'body' }, { char: '>' },
              { etag_open: '</' }, { name: 'body' }, { char: '>' },
              { etag_open: '</' }, { name: 'html' }, { char: '>' }
            ],
            expected: []
          }
        end
      end

      it 'recognizes a valid sentence with multiple terms' do
        check do
          {
            given: [
              { char: '<' }, { name: 'html' }, { char: '>' },
              { char: '<' }, { name: 'body' }, { char: '>' },
              { char: '<' }, { name: 'header' }, { char: '>' },
              { etag_open: '</' }, { name: 'header' }, { char: '>' },
              { char: '<' }, { name: 'footer' }, { char: '>' },
              { etag_open: '</' }, { name: 'footer' }, { char: '>' },
              { etag_open: '</' }, { name: 'body' }, { char: '>' },
              { etag_open: '</' }, { name: 'html' }, { char: '>' }
            ],
            expected: []
          }
        end
      end

      it 'does not recognizes a sentence with multiple numbers' do
        check do
          {
            given: [
              { char: '<' }, { name: 'html' }, { char: '>' },
              { char: '<' }, { name: 'body' }, { char: '>' },
              { number: 123 },
              { number: 456 },
              { etag_open: '</' }, { name: 'body' }, { char: '>' },
              { etag_open: '</' }, { name: 'html' }, { char: '>' }
            ],
            expected: [
              { missing: :etag_open, found: { number: 456 } },
              { missing: { any: %i[name name_regex] }, found: { number: 456 } },
              { missing: '>', found: { number: 456 } }
            ]
          }
        end
      end

      it 'does not recognize a sentence missing initial character' do
        check do
          {
            given: [
              { name: 'html' }, { char: '>' },
              { etag_open: '</' }, { name: 'html' }, { char: '>' }
            ],
            expected: [{ missing: '<', found: { name: 'html' } }]
          }
        end
      end

      it 'does not recognize a sentence missing final character' do
        check do
          {
            given: [
              { char: '<' }, { name: 'html' }, { char: '>' },
              { etag_open: '</' }, { name: 'html' }
            ],
            expected: [{ missing: '>' }]
          }
        end
      end

      it 'does not recognize a sentence with an extra character' do
        check do
          {
            given: [
              { char: '<' }, { name: 'html' }, { char: '>' },
              { etag_open: '</' }, { name: 'html' }, { char: '>' }, { char: '>' }
            ],
            expected: [{ unrecognized: '>' }]
          }
        end
      end

    end

  end

end

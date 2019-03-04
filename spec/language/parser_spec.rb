require 'language'

module MPF

  RSpec.describe Language::External::Parser do

    def check
      rules = {
        element: %i[stag content? etag],
        stag: ['<', :name, '>'],
        etag: ['</', :name, '>'],
        content: [{ any: %i[name number element] }]
      }
      @parser = Language::External::Parser.new(grammar: rules)
      options = yield
      errors = @parser.parse(options[:given])
      expect(errors).to eq(options[:expected])
    end

    describe '#parse' do

      it 'recognizes a valid sentence without optional' do
        check do
          {
            given: [
              { char: '<' }, { name: 'html' }, { char: '>' },
              { char: '</' }, { name: 'html' }, { char: '>' }
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
              { name: 'text' },
              { char: '</' }, { name: 'html' }, { char: '>' }
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
              { char: '</' }, { name: 'html' }, { char: '>' }
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
              { char: '</' }, { name: 'body' }, { char: '>' },
              { char: '</' }, { name: 'html' }, { char: '>' }
            ],
            expected: []
          }
        end
      end

      it 'does not recognize a sentence missing initial character' do
        check do
          {
            given: [
              { name: 'html' }, { char: '>' },
              { char: '</' }, { name: 'html' }, { char: '>' }
            ],
            expected: [{ missing: '<' }]
          }
        end
      end

      it 'does not recognize a sentence missing final character' do
        check do
          {
            given: [
              { char: '<' }, { name: 'html' }, { char: '>' },
              { char: '</' }, { name: 'html' }
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
              { char: '</' }, { name: 'html' }, { char: '>' }, { char: '>' }
            ],
            expected: [{ unrecognized: '>' }]
          }
        end
      end

    end

  end

end

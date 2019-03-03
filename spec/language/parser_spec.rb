require 'language'

module MPF

  RSpec.describe Language::Parser do

    def check
      rules = {
        element: %i[stag etag],
        stag: ['<', :name, '>'],
        etag: ['</', :name, '>']
      }
      @parser = Language::Parser.new(grammar: rules)
      options = yield
      errors = @parser.parse(options[:given])
      expect(errors).to eq(options[:expected])
    end

    describe '#parse' do

      it 'recognizes a valid sentence' do
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

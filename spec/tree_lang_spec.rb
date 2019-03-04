require 'tree_lang'

module MPF

  source_code = TreeLang.source do
    node(:html, lang: 'en') do
      node(:head) do
        node(:title) { 'Books' }
      end
      node(:body) do
        node(:div, class: 'header') do
          node(:img, src: 'logo.png', alt: 'Books Logo')
        end
      end
    end
  end

  source_code.print(to: :xml)
  print "\n\n"

  model = source_code.build
  print model.inspect
  print "\n\n"

  source_code = TreeLang.emit(from: model)
  source_code.print(to: :xml)
  print "\n\n"

  target_code = source_code.render(to: :xml)
  print target_code
  print "\n\n"

  print'>>> Parsing from XML:\n'
  model, errors = TreeLang.parse(from: :xml, text: target_code)
  if errors.empty?
    TreeLang.emit(from: model).print(to: :xml)
  else
    errors.each { |error| print "\nError: #{error}" }
  end
  print "\n\n"

  RSpec.describe 'tree_lang' do
    # it 'translates the layout elements to a div' do
    #   # expected_target = '<div class="container"></div>'
    #   # actual_target = StructLang.translate source: given_source, to: :xml
    #   # expect(actual_target).to eq(expected_target)
    # end
  end

end
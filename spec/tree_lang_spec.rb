require 'tree_lang'

source_code = TreeLang.source do
  node(:html, lang: 'en') do
    node(:head) { node(:title) { 'Books' } }
    node(:body) do
      node(:div, class: 'header') { node(:img, src: 'logo.png', alt: 'Books Logo') }
      node(:div, class: 'main') do
        node(:span, class: 'largeHeading') do
          content 'Favorite'
          node(:b) { 'Books' }
        end
      end
    end
  end
end

source_code.print(to: :xml)
print "\n\n"

target_code = source_code.render(to: :xml)
print target_code
print "\n\n"

model = source_code.build
print model.inspect
print "\n\n"

source_code = TreeLang.emit(from: model)
source_code.print(to: :xml)
print "\n\n"

# source_code.execute

RSpec.describe 'tree_lang' do
  # it 'translates the layout elements to a div' do
  #   # expected_target = '<div class="container"></div>'
  #   # actual_target = StructLang.translate source: given_source, to: :xml
  #   # expect(actual_target).to eq(expected_target)
  # end
end
RSpec.describe Bootlang::Translator do
  it 'translates the layout elements to a div' do
    given_source = '<container></container>'
    expected_target = '<div class="container"></div>'
    expect(Bootlang::Translator.translate(given_source)).to eq(expected_target)
  end
end

RSpec.describe BootLang do
  it 'translates the layout elements to a div' do
    given_source = '<container></container>'
    expected_target = '<div class="container"></div>'
    expect(BootLang.translate(given_source)).to eq(expected_target)
  end
end

class Text::Token

  attr_reader :category
  attr_reader :text

  def initialize(options = {})
    @category = options.first[0]
    @text = options.first[1]
  end

  def raw
    { @category => @text }
  end

  def ==(other)
    return false unless other.is_a? Token
    return true if other.equal? self

    @category == other.category and @text == other.text
  end

  def hash
    (category.to_s + text.to_s).hash
  end

end

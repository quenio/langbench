module TextRenderer

  attr_reader :text

  def init_text_rendering
    @text = ''
  end

  def print(value)
    @text << value
  end

end
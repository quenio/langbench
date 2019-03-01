module TextRenderer

  attr_reader :text

  def init_rendering
    @text = ''
  end

  def print(value)
    @text << value
  end

end
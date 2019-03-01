module XmlTemplate

  def open_markup(name, attributes)
    "<#{name}#{attributes_list(attributes)}>"
  end

  def close_markup(name)
    "</#{name}>"
  end

  def inner_content(value)
    value.to_s
  end

  def attributes_list(attributes)
    result = attributes.map { |attrib| "#{attrib[0]}=\"#{attrib[1]}\"" }.join(' ')
    result = ' ' + result unless result.empty?
    result
  end

end
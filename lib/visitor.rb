module Visitor

  def visit_node(name, attributes = {}, &block)
    enter_node(name, attributes, &block)
    visit_children(&block) if block
    exit_node(name, attributes, &block)
  end

  def enter_node(_name, _attributes, &_block)
    raise 'Not implemented.'
  end

  def exit_node(_name, _attributes, &_block)
    raise 'Not implemented.'
  end

  def visit_children
    value = yield
    visit_content(value) if value
  end

  def visit_content(_value)
    raise 'Not implemented.'
  end

end
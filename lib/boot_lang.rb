require 'bootlang/version'
require 'lang_lang'

module BootLang

  include LangLang

  REGEX = %r{\A\s*<([A-Za-z0-9]+)>\s*</([A-Za-z0-9]+)>\s*\z}.freeze

  RULE = lambda do |tokens|
    raise "Expected 2 tokens but found: #{tokens}" if tokens.length != 2
    raise "Expected matching elements but found: #{tokens}" if tokens[0] != tokens[1]

    Element.new(tokens[0])
  end

  TEMPLATE = lambda do |element|
    "<div class=\"#{element.name}\"></div>"
  end

  class Element

    def initialize(name)
      @name = name
    end

    attr_reader :name

  end

end

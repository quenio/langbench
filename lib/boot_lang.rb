require 'bootlang/version'
require 'lang_lang'

module BootLang

  include LangLang

  def self.translate(source)
    translator = Translator.new tokenizer: Tokenizer.new,
                                parser: Parser.new,
                                renderer: Renderer.new
    translator.translate source
  end

  class Element

    def initialize(name)
      @name = name
    end

    attr_reader :name

  end

  class Tokenizer

    def tokenize(source)
      source.scan(%r{\A\s*<([A-Za-z0-9]+)>\s*</([A-Za-z0-9]+)>\s*\z})[0]
    end

  end

  class Parser

    def parse(tokens)
      raise "Expected 2 tokens but found: #{tokens}" if tokens.length != 2
      raise "Expected matching elements but found: #{tokens}" if tokens[0] != tokens[1]

      Element.new(tokens[0])
    end

  end

  class Renderer

    def render(element)
      "<div class=\"#{element.name}\"></div>"
    end

  end

end

require 'bootlang/version'

module Bootlang

  class Error < StandardError; end

  class Element

    def initialize(name)
      @name = name
    end

    attr_reader :name

  end

  module Translator

    def self.translate(source)
      Renderer.render(Parser.parse(Tokenizer.tokenize(source)))
    end

  end

  module Tokenizer

    def self.tokenize(source)
      source.scan(%r{\A\s*<([A-Za-z0-9]+)>\s*</([A-Za-z0-9]+)>\s*\z})[0]
    end

  end

  module Parser

    def self.parse(tokens)
      raise "Expected 2 tokens but found: #{tokens}" if tokens.length != 2
      raise "Expected matching elements but found: #{tokens}" if tokens[0] != tokens[1]

      Element.new(tokens[0])
    end

  end

  module Renderer

    def self.render(element)
      "<div class=\"#{element.name}\"></div>"
    end

  end

end

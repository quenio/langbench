# lang_lang.rb

module LangLang

  def self.included(base)
    base.class_eval do
      def self.translate(source)
        translator = Translator.new tokenizer: Tokenizer.new(regex: self::REGEX),
                                    parser: Parser.new(rule: self::RULE),
                                    renderer: Renderer.new(template: self::TEMPLATE)
        translator.translate source
      end
    end
  end

  class Translator

    attr_reader :tokenizer
    attr_reader :parser
    attr_reader :renderer

    def initialize(options = {})
      @tokenizer = options[:tokenizer]
      @parser = options[:parser]
      @renderer = options[:renderer]
    end

    def translate(source)
      @renderer.render(@parser.parse(@tokenizer.tokenize(source)))
    end

  end

  class Tokenizer

    attr_reader :regex

    def initialize(options = {})
      @regex = options[:regex]
    end

    def tokenize(source)
      source.scan(@regex)[0]
    end

  end

  class Parser

    attr_reader :rule

    def initialize(options = {})
      @rule = options[:rule]
    end

    def parse(tokens)
      @rule.call(tokens)
    end

  end

  class Renderer

    attr_reader :template

    def initialize(options = {})
      @template = options[:template]
    end

    def render(element)
      @template.call(element)
    end

  end

end
# lang_lang.rb

module LangLang

  def self.included(_module)
    _module.extend Methods
  end

  module Methods

    def skip(regex)
      @tokenizer_options = (@tokenizer_options ||= {}).merge(skip: regex)
    end

    def tokens(rules = {})
      @tokenizer_options = (@tokenizer_options ||= {}).merge(rules: rules)
    end

    def grammar(rules = {})
      @parser_options = (@parser_options ||= {}).merge(grammar: rules)
    end

    def on(_rule_id, &_action)
    end

    def translate(source)
      translator = Translator.new tokenizer: Tokenizer.new(@tokenizer_options),
                                  parser: Parser.new(@parser_options),
                                  renderer: Renderer.new(template: self::TEMPLATE)
      translator.translate source
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

  class Renderer

    attr_reader :template

    def initialize(options = {})
      @template = options[:template]
    end

    def render(element)
      # @template.call(element)
      element
    end

  end

end
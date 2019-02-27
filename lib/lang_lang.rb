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

    def grammar(_rules = {})

    end

    def translate(source)
      translator = Translator.new tokenizer: Tokenizer.new(@tokenizer_options),
                                  parser: Parser.new(rule: self::RULE),
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

  class Tokenizer

    attr_reader :skip
    attr_reader :rules

    def initialize(options = {})
      @skip = options[:skip]
      @rules = options[:rules]
    end

    def tokenize(source)
      source = source.dup
      tokens = []
      skip!(source)
      until source.empty?
        token = next!(source)
        tokens.push(token) if token
        skip!(source) if source
      end
      tokens
    end

    def skip!(source)
      substr = source[@skip]
      substr ? (source.sub! substr, '') : source
    end

    def next!(source)
      token = next_token(source)
      if not token or not source.start_with? token.values[0]
        token = { char: source[0] } unless source.empty?
      end
      source.sub! token.values[0], '' if token
      token
    end

    def next_token(source)
      rules = @rules.dup
      rule = rules.shift
      token = nil
      while rule and (not token or not source.start_with? token)
        token = source[rule[1]]
        id = rule[0]
        rule = rules.shift
      end
      { id => token } if token
    end

  end

  class Parser

    attr_reader :rule

    def initialize(options = {})
      @rule = options[:rule]
    end

    def parse(tokens)
      # @rule.call(tokens)
      tokens
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
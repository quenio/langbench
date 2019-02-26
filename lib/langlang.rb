# langlang.rb

module LangLang

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

end
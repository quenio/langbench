module MetaLang

  module Internal

    module Syntax

      def initialize(options = {})
        @tokenizer = options[:tokenizer]
        @parser = options[:parser]
      end

      def skip(regex)
        @tokenizer.skip = regex
      end

      def tokens(rules = {})
        @tokenizer.rules = rules
      end

      def grammar(rules = {})
        @parser.grammar = rules
      end

      def evaluate(&source_code)
        instance_eval &source_code
      end

    end

  end

end
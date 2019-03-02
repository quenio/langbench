module MetaLang

  module Internal

    module Syntax

      def skip(regex)
        @tokenizer_options = (@tokenizer_options ||= {}).merge(skip: regex)
      end

      def tokens(rules = {})
        @tokenizer_options = (@tokenizer_options ||= {}).merge(rules: rules)
      end

      def grammar(rules = {})
        @parser_options = { grammar: rules }
      end

      def evaluate(&source_code)
        instance_eval &source_code
      end

    end

  end

end
require 'mpf/meta'
require 'mpf/external/text'
require 'mpf/external/parser'

module MPF

  module External

    class Syntax

      class << self
        attr_accessor :skip_regex
        attr_accessor :token_rules
        attr_accessor :grammar_rules
        attr_accessor :pre_actions
        attr_accessor :post_actions
      end

      def self.skip(regex)
        @skip_regex = regex
      end

      def self.tokens(rules = {})
        @token_rules = rules
      end

      def self.grammar(rules = {})
        @grammar_rules = rules
      end

      def self.before(rule_name, &block)
        (@pre_actions ||= {})[rule_name] = block
      end

      def self.after(rule_name, &block)
        (@post_actions ||= {})[rule_name] = block
      end

      def parse(options = {})
        tokenizer = Text::Tokenizer.new(
          skip: self.class.skip_regex,
          rules: self.class.token_rules
        )
        parser = Parser.new(
          tokenizer: tokenizer,
          grammar: self.class.grammar_rules,
          visitor: options[:visitor],
          pre_actions: self.class.pre_actions,
          post_actions: self.class.post_actions,
          ignore_actions: options[:ignore_actions]
        )
        parser.parse(options[:text])
      end

    end

  end

end

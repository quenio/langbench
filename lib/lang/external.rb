require 'text/tokenizer'
require 'lang/meta'

module Lang::External

  module Syntax

    def self.included(mod)
      mod.extend self
    end

    def skip(regex)
      @skip_regex = regex
    end

    def tokens(rules = {})
      @token_rules ||= {}
      @token_rules = rules.dup.merge(@token_rules)
    end

    def grammar(rules = {})
      @grammar_rules ||= {}
      @grammar_rules = @grammar_rules.merge(rules)
    end

    def before(rule_name, &block)
      (@pre_actions ||= {})[rule_name] = block
    end

    def after(rule_name, &block)
      (@post_actions ||= {})[rule_name] = block
    end

    def parse(options = {})
      tokenizer = Text::Tokenizer.new(
        skip: @skip_regex,
        rules: @token_rules
      )
      parser = Text::Parser.new(
        tokenizer: tokenizer,
        grammar: @grammar_rules,
        visitor: options[:visitor],
        pre_actions: @pre_actions,
        post_actions: @post_actions,
        ignore_actions: options[:ignore_actions]
      )
      parser.parse(options[:text])
    end

  end

end

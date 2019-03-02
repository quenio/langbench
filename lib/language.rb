require 'text'

module MPF

  module Language

    module External

      class Syntax

        class << self
          attr_accessor :skip_regex
          attr_accessor :token_rules
          attr_accessor :grammar_rules
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

        def parse(options = {})
          tokenizer = Text::Tokenizer.new(
            skip: self.class.skip_regex,
            rules: self.class.token_rules
          )
          parser = Language::Parser.generate(
            grammar: self.class.grammar_rules,
            visitor: options[:visitor]
          )
          parser.parse(tokenizer.tokenize(options[:text]))
        end

      end

    end

    class Parser

      class Rule

        attr_reader :name
        attr_reader :terms

        def initialize(name, terms)
          @name = name
          @terms = terms
        end

        def method_name
          "#{name}_rule"
        end

      end

      class Grammar

        def self.of(rules)
          rules.map { |rule| Rule.new(*rule) }
        end

      end

      def self.generate(options = {})
        grammar = Grammar.of(options[:grammar])
        Class.new(Parser) { define_parser(self, grammar) }.new
      end

      def self.define_parser(parser, grammar)
        grammar.each { |rule| define_rule(parser, rule) }
        define_parse(parser, grammar)
      end

      def self.define_parse(parser, grammar)
        parser.define_method(:parse) do |tokens|
          init_parsing(grammar, tokens)
          next_token
          invoke(grammar.first)
          check_pending_tokens
          [nil, @errors]
        end
      end

      def self.define_rule(parser, rule)
        parser.define_method(rule.method_name) do
          print "\n>>> Enter: #{rule.name}"
          rule.terms.each { |term| evaluate(term) }
          print "\n>>> Exit: #{rule.name}"
        end
      end

      private

      def init_parsing(grammar, tokens)
        @grammar = grammar.map { |rule| [rule.name, rule] }.to_h
        @tokens = tokens
        @token = nil
        @errors = []
      end

      def next_token
        if @tokens.any?
          @token, *@tokens = @tokens
        else
          @token = nil
        end
        print "\n>>> Next Token: #{@token&.inspect}"
      end

      def error(options = {})
        @errors << options
        print "\n>>> Error: #{options.inspect}"
      end

      def invoke(rule)
        send(rule.method_name)
      end

      def check_pending_tokens
        error(unrecognized: text_of(@token)) if @token and @errors.empty?
      end

      def evaluate(term)
        if non_terminal? term
          invoke(rule_of(term))
        else
          expect?(term)
        end
      end

      def expect?(term)
        accepted = accept? term
        error(missing: term) unless accepted
        accepted
      end

      def accept?(term)
        accepted = (@token and (@token == { char: term } or category_of(@token) == term))
        print "\n>>> Accepted Token: #{@token&.inspect} - Matched: #{term.inspect}" if accepted
        next_token if accepted
        accepted
      end

      def category_of(token)
        token.first[0]
      end

      def text_of(token)
        token.first[1]
      end

      def non_terminal?(term)
        term.is_a? Symbol and rule_of(term)
      end

      def rule_of(term)
        @grammar[term]
      end

    end

    module Visitor

      def visit_node(name, attributes = {}, &block)
        enter_node(name, attributes, &block)
        visit_children(&block) if block
        exit_node(name, attributes, &block)
      end

      def enter_node(_name, _attributes = {}, &_block)
        raise 'Not implemented.'
      end

      def exit_node(_name, _attributes = {}, &_block)
        raise 'Not implemented.'
      end

      def visit_children
        value = yield
        visit_content(value) if value
      end

      def visit_content(_value)
        raise 'Not implemented.'
      end

    end

  end

end

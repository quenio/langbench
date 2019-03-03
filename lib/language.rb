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
          parser = Language::Parser.new(
            grammar: self.class.grammar_rules,
            visitor: options[:visitor]
          )
          parser.parse(tokenizer.tokenize(options[:text]))
        end

      end

    end

    class Parser

      MAX_ERROR_COUNT = 3

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

      def initialize(options = {})
        grammar = Grammar.of(options[:grammar])
        @start_rule = grammar.first
        @grammar = grammar.map { |rule| [rule.name, rule] }.to_h
        @tokens = []
      end

      def parse(tokens)
        raise 'Parser already running.' if @token or @tokens.any?

        @tokens = tokens.dup
        @token = nil
        @errors = []

        next_token
        execute_rule @start_rule
        check_pending_tokens

        @errors
      end

      private

      def next_token
        if @tokens.any?
          @token, *@tokens = @tokens
        else
          @token = nil
        end
        log "\n>>> Next Token: #{@token.inspect}"
      end

      def error(options = {})
        @errors << options
        log "\n>>> Error: #{options.inspect}"
      end

      def check_pending_tokens
        error(unrecognized: text_of(@token)) if @token and @errors.empty?
      end

      def execute_rule(rule, optional = false)
        log "\n>>> execute_rule(#{rule.name}, optional: #{optional})"
        first, *rest = rule.terms
        verify_term(first, rest, optional) if first
        while rest.any? and @errors.length < MAX_ERROR_COUNT
          term, *rest = rest
          verify_term(term)
        end
        log "\n>>> Exit: #{rule.name}"
      end

      def verify_term(term, rest = {}, optional = false)
        log "\n>>> verify_term(#{term.inspect}, optional: #{optional.inspect})"
        if non_terminal? term
          execute_rule rule_of(term), optional || optional?(term)
        elsif match? term
          log "\n>>> Token Match: #{@token&.inspect} - term: #{term}"
          next_token
        elsif optional
          rest.clear
        else
          log "\n>>> Error: #{@token&.inspect} - term: #{term}" unless optional
          error(missing: term)
        end
      end

      def match?(term)
        @token and (@token == { char: term } or category_of(@token) == raw(term))
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
        @grammar[raw(term)]
      end

      def raw(term)
        if term.is_a? Symbol
          term[/\A(\w+)/].to_sym
        else
          term
        end
      end

      def optional?(term)
        term&.is_a? Symbol and term.to_s.end_with? '?'
      end

      def log(_message)
        # print _message
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

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

      def initialize(options = {})
        @grammar = options[:grammar]
        @visitor = options[:visitor]
      end

      def parse(tokens)
        token_consumed = true
        rule = @grammar.first
        seq = right_term_of(rule).dup # sequence of first rule
        stream = tokens.dup

        until stream.empty?
          print "\n"
          if token_consumed
            token, *stream = stream
          elsif optional?(parent ||= nil)
            seq = skip(parent, seq)
            print "\n>>> skip:#{seq.inspect} "
          end

          print "\n>>> before:#{seq.inspect} "
          parent, term, seq = next_term(seq)
          print "\n>>> after:#{seq.inspect} "

          @visitor&.enter_node(term)
          print "\n>>> enter_node(#{term.inspect}) - token: #{token} - parent: #{parent.inspect}"

          return [{ unrecognized: text_of(token) }] unless term
          return [{ missing: term }] unless match?(term, token) or optional?(parent)

          token_consumed = match?(term, token)
        end

        _parent, term, _seq = next_term(seq)
        term ? [{ missing: term }] : []
      end

      private

      def next_term(seq)
        parent = nil
        term, *seq = seq
        while @grammar[raw(term)]
          parent = term
          term, *rest = @grammar[raw(term)]
          seq = rest + seq
        end
        [parent, term, seq]
      end

      def raw(term)
        if term&.is_a? Symbol
          term[/\A(\w+)/].to_sym
        else
          term
        end
      end

      def skip(parent, seq)
        skipped = @grammar[raw(parent)].dup
        skipped.shift until skipped.first == seq.first
        while skipped.any?
          skipped.shift
          seq.shift
        end
        seq
      end

      def match?(term, token)
        token == { char: term } or category_of(token) == term
      end

      def optional?(term)
        term&.is_a? Symbol and term.to_s.end_with? '?'
      end

      def first_child?(parent, term)
        @grammar[raw(parent)]&.first == term
      end

      def left_term_of(rule)
        print ">>> extract: #{rule[0][/\A(.*)\?/][1]}"
        rule[0][/\A(.*)\?/][1]
      end

      def right_term_of(rule)
        rule[1]
      end

      def category_of(token)
        token.first[0]
      end

      def text_of(token)
        token.first[1]
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

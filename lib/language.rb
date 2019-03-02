module MPF

  module Language

    class Parser

      def initialize(options = {})
        @grammar = options[:grammar]
        @visitor = options[:visitor]
      end

      def parse(tokens)
        rule = @grammar.first
        seq = right_term_of(rule).dup # sequence of first rule
        stream = tokens.dup
        until stream.empty?
          token, *stream = stream
          term, *seq = next_term(seq)
          @visitor&.enter_node(term)
          print "\n>>> enter_node(#{term}) - token: #{token}"
          return [{ unrecognized: text_of(token) }] unless term
          return [{ missing: term }] unless token == { char: term } or category_of(token) == term
        end
        term = next_term(seq)&.first
        term ? [{ missing: term }] : []
      end

      private

      def next_term(seq)
        term, *seq = seq
        while @grammar[term]
          term, *rest = @grammar[term]
          seq = rest + seq
        end
        term ? seq.unshift(term) : seq
      end

      def left_term_of(rule)
        rule[0]
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

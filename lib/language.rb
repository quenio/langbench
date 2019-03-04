require 'text'

module MPF

  module Language

    module Visitor

      def enter_node(_name, _attributes = {}, &_block)
        raise 'Not implemented.'
      end

      def exit_node(_name, _attributes = {}, &_block)
        raise 'Not implemented.'
      end

      def visit_content(_value)
        raise 'Not implemented.'
      end

    end

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
          parser = Language::External::Parser.new(
            grammar: self.class.grammar_rules,
            visitor: options[:visitor],
            pre_actions: self.class.pre_actions,
            post_actions: self.class.post_actions,
            ignore_actions: options[:ignore_actions]
          )
          parser.parse(tokenizer.tokenize(options[:text]))
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
          @visitor = options[:visitor]
          @pre_actions = options[:pre_actions] || {}
          @post_actions = options[:post_actions] || {}
          @ignore_actions = options[:ignore_actions] || false
          @action_context = Object.new unless @ignore_actions
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
          attributes = {}
          enter_node(rule)
          first, *rest = rule.terms
          verify_term(attributes, first, rest, optional) if first
          while rest.any? and @errors.length < MAX_ERROR_COUNT
            term, *rest = rest
            verify_term(attributes, term)
          end
          exit_node(rule, attributes)
          log "\n>>> Exit: #{rule.name}"
        end

        def enter_node(rule)
          if @ignore_actions
            @visitor&.enter_node(rule.name)
          else
            action = @pre_actions[rule.name]
            @action_context.instance_exec(@visitor, &action) if action
          end
        end

        def exit_node(rule, attributes)
          if @ignore_actions
            @visitor&.exit_node(rule.name, attributes)
          else
            action = @post_actions[rule.name]
            @action_context.instance_exec(attributes, @visitor, &action) if action
          end
        end

        def verify_term(attributes, term, rest = {}, optional = false)
          if alternative? term
            subterm = alternatives_of(term).detect do |subterm|
              match? first_of(subterm)
            end
            term = subterm if subterm
          end
          log "\n>>> verify_term(#{term.inspect}, optional: #{optional.inspect})"
          if non_terminal? term
            execute_rule rule_of(term), optional || optional?(term)
          elsif match? term
            log "\n>>> Token Match: #{@token&.inspect} - term: #{term}"
            attributes[category_of(@token)] = text_of(@token) if category_of(@token) != :char
            next_token
          elsif optional
            rest.clear
          else
            log "\n>>> Error: #{@token&.inspect} - term: #{term}" unless optional
            error(missing: term)
          end
        end

        def alternative?(term)
          term.is_a? Hash and alternatives_of(term)
        end

        def non_terminal?(term)
          term.is_a? Symbol and rule_of(term)
        end

        def match?(term)
          @token and (@token == { char: term } or category_of(@token) == raw(term))
        end

        def first_of(term)
          term, *_rest = rule_of(term).terms while non_terminal? term
          term
        end

        def alternatives_of(term)
          term[:any]
        end

        def category_of(token)
          token.first[0]
        end

        def text_of(token)
          token.first[1]
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

      module ParseTree

        module Template

          def opened_node(name, attributes)
            "#{name}{#{attributes_list(attributes)}}"
          end

          def closed_node(name, attributes)
            "/#{name}{#{attributes_list(attributes)}}"
          end

          def inner_content(value)
            value.to_s
          end

          def attributes_list(attributes)
            result = attributes.map { |attrib| "#{attrib[0]}=\"#{attrib[1]}\"" }.join(', ')
            result = ' ' + result + ' ' unless result.empty?
            result
          end

        end

        class Printer

          include Visitor
          include Template
          include Text::Printer

          def initialize
            init_indentation
          end

          def enter_node(name, attributes = {})
            enter_section
            indent_print opened_node(name, attributes)
            indent
          end

          def exit_node(name, attributes = {})
            unindent
            indent_print closed_node(name, attributes)
            exit_section
          end

        end

      end

    end

    module Internal

      class Syntax

        def self.evaluate(options = {}, &source_code)
          new(options).instance_eval &source_code
        end

        private

        def initialize(options = {})
          @visitor = options[:visitor]
        end

      end

    end

  end

end

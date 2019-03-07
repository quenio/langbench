require 'text'
require 'language/external/grammar'

module MPF

  module Language

    module External

      class Parser

        MAX_ERROR_COUNT = 3

        def initialize(options = {})
          @tokenizer = options[:tokenizer] || Text::Tokenizer.new
          @grammar = Grammar.new(options[:grammar])
          @visitor = options[:visitor]
          @pre_actions = options[:pre_actions] || {}
          @post_actions = options[:post_actions] || {}
          @ignore_actions = options[:ignore_actions] || false
          @action_context = Object.new unless @ignore_actions
          @text = ''
        end

        def parse(text)
          raise 'Parser already running.' if @token or not @text.empty?

          @text = text.dup
          @token = nil
          @errors = []

          next_token
          execute_rule @grammar.start_rule
          check_pending_tokens

          @errors
        end

        private

        def next_token(term = nil)
          if term
            raise "Method requires regex term or none, but found: #{term.inspect}" unless term&.regex?

            saved_rules = @tokenizer.rules
            @tokenizer.rules = { term.raw => term.regex }
            @text = @token.text + @text if @token
          end
          @tokenizer.skip!(@text)
          @token = @text.empty? ? nil : @tokenizer.next!(@text)
          @tokenizer.rules = saved_rules if term
        end

        def error(options = {})
          @errors << options
          log "\n>>> Error: #{options.inspect}"
        end

        def check_pending_tokens
          error(unrecognized: @token.text) if @token and @errors.empty?
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

        def verify_term(attributes, term, rest = {}, optional = false)
          if term.alternative?
            subterm = term.alternatives.detect do |subterm|
              match? subterm.firsts
            end
            term = subterm if subterm
          end
          if term.regex?
            next_token(term)
            optional ||= term.optional?
          end
          log "\n>>> verify_term(#{term.raw.inspect}, optional: #{optional.inspect})"
          if term.rule?
            loop do
              execute_rule term.def_rule, optional || term.optional?
              break unless term.multiple? and match? term.firsts

              log "\n>>> Multiples of term: #{term.raw.inspect}"
            end
          elsif match? term
            log "\n>>> Token Match: #{@token&.raw.inspect} - term: #{term.raw.inspect}"
            attributes[@token.category] = @token.text if @token.category != :char
            next_token
            log "\n>>> Next Token: #{@token&.raw.inspect}"
          elsif optional
            rest.clear unless term.optional?
          else
            log "\n>>> Error: #{@token&.raw.inspect} - term: #{term.raw.inspect}"
            if @token
              error(missing: term.raw, found: @token.raw)
            else
              error(missing: term.raw)
            end
          end
        end

        def match?(*terms)
          return false unless @token

          terms.flat_map { |t| t }.any? do |term|
            if term.is_a? Regexp
              @token.category == :char and @token.text[term] == @token.text
            elsif term.is_a? Grammar::TextTerm
              term.match? @token
            elsif term.is_a? Grammar::RuleTerm
              term.match? @token
            else
              @token.category == term.raw
            end
          end
        end

        def log(_message)
          # print _message
        end

      end

    end

  end

end

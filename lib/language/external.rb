require 'language/meta'
require 'language/external/text'
require 'language/external/parser'

module MPF

  module Language

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
            result = attributes.map { |attrib| "#{attrib[0]}=#{attrib[1].inspect}" }.join(', ')
            result = ' ' + result + ' ' unless result.empty?
            result
          end

        end

        class Printer

          include Meta::Visitor
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

  end

end

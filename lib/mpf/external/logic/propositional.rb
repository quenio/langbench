require 'mpf/external/parse_tree'
require 'mpf/external/logic'

module MPF

  module External

    module Logic

      module Propositional

        class Syntax < MPF::External::Logic::Syntax

          skip /\s*/

          tokens proposition_literal: /true|false/,
                 proposition_prefix: /not/,
                 proposition_infix: /and|or|implies|iif/,
                 proposition_variable: /[a-z][a-z0-9_]*/

          grammar proposition: %i[basic_proposition binary_proposition*],
                  basic_proposition:
                    {
                      any: %i[proposition_literal proposition_variable unary_proposition]
                    },
                  unary_proposition: %i[proposition_prefix proposition],
                  binary_proposition: %i[proposition_infix proposition]

          after :basic_proposition do |attributes, interpreter|
            interpreter.evaluate_basic_proposition(attributes)
          end

          after :unary_proposition do |attributes, interpreter|
            interpreter.evaluate_unary_proposition(attributes)
          end

          after :binary_proposition do |attributes, interpreter|
            interpreter.evaluate_binary_proposition(attributes)
          end

        end

        class Interpreter

          attr_reader :values

          def initialize(interpretation = {})
            @values = []
            @interpretation = interpretation.merge(
              true: true,
              false: false,
              not: {
                true => false,
                false => true
              },
              and: {
                true => {
                  true => true,
                  false => false
                },
                false => {
                  true => false,
                  false => false
                }
              },
              or: {
                true => {
                  true => true,
                  false => true
                },
                false => {
                  true => true,
                  false => false
                }
              }
            )
          end

          def evaluate_basic_proposition(attributes = {})
            variable_name = attributes[:proposition_variable]
            literal_name = attributes[:proposition_literal]
            @values.push(@interpretation[variable_name.to_sym]) if variable_name
            @values.push(@interpretation[literal_name.to_sym]) if literal_name
          end

          def evaluate_unary_proposition(attributes = {})
            proposition_prefix = attributes[:proposition_prefix]
            return unless proposition_prefix
            return if @values.empty?

            @values.push(@interpretation[proposition_prefix.to_sym][@values.pop])
          end

          def evaluate_binary_proposition(attributes = {})
            proposition_infix = attributes[:proposition_infix]
            return unless proposition_infix
            return unless @interpretation[proposition_infix.to_sym]
            return if @values.empty?

            @values.push(@interpretation[proposition_infix.to_sym][@values.pop][@values.pop])
          end

        end

        def self.interpret(params = {})
          # printer = MPF::External::ParseTree::Printer.new
          # errors = Syntax.new.parse(text: params[:text], visitor: printer, ignore_actions: true)
          # [errors, true]
          interpreter = Interpreter.new(params[:interpretation] || {})
          errors = Syntax.new.parse(text: params[:text], visitor: interpreter)
          [errors, interpreter.values.pop]
        end

        class Sentence

          def initialize(text)
            @text = text
          end

          def satisfied_by?(interpretation = {})
            errors, value = Propositional.interpret(text: @text, interpretation: interpretation)
            errors.empty? and value
          end

        end

        def self.sentence(text)
          Sentence.new(text)
        end

        def self.proposition(text)
          sentence(text)
        end

      end

    end

  end

end

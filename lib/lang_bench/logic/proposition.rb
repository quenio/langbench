# frozen_string_literal: true

#--
# Copyright (c) 2019 Quenio Cesar Machado dos Santos
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software
# and associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute,
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++
#

module LangBench
  module Logic
    module PropositionLogic
      module Syntax
        include External::Syntax

        skip regex: /\s*/

        tokens proposition_literal: /true|false/,
               proposition_prefix: /not/,
               proposition_infix: /and|or|if|iif/,
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
        class << self
          attr_accessor :interpretation
        end

        def self.interpret(rules)
          @interpretation ||= {}
          @interpretation = @interpretation.merge(rules)
        end

        interpret true: true

        interpret false: false

        interpret not: {
          true => false,
          false => true
        }

        interpret and: {
          true => {
            true => true,
            false => false
          },
          false => {
            true => false,
            false => false
          }
        }

        interpret or: {
          true => {
            true => true,
            false => true
          },
          false => {
            true => true,
            false => false
          }
        }

        interpret if: {
          true => {
            true => true,
            false => false
          },
          false => {
            true => true,
            false => true
          }
        }

        interpret iif: {
          true => {
            true => true,
            false => false
          },
          false => {
            true => false,
            false => true
          }
        }

        attr_reader :values

        def initialize(interpretation = {})
          @values = []
          @interpretation = interpretation.merge(Interpreter.interpretation)
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
        errors = Syntax.parse(text: params[:text], visitor: interpreter)
        [errors, interpreter.values.pop]
      end

      class Sentence
        def initialize(text)
          @text = text
        end

        def satisfied_by?(interpretation = {})
          errors, value = Proposition.interpret(
            text: @text,
            interpretation: interpretation
          )
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

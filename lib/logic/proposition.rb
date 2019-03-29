require 'lang/external'

module Logic

  module Proposition

    module Syntax

      include Lang::External::Syntax

      skip /\s*/

      tokens proposition_literal: /true|false/,
             proposition_variable: /[a-z][a-z0-9_]*/,
             proposition_prefix: /not/,
             proposition_infix: /and|or|if|iif/

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
        variable_name = attributes[:variable]
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

require 'text/parser/tree'
require 'logic/proposition'

module Logic

  module Predicate

    module Syntax

      include Propositional::Syntax

    end

    class Interpreter < Proposition::Interpreter

      def initialize(interpretation)
        super(interpretation)
      end

    end

    def self.interpret(params = {})
      # printer = Lang::External::ParseTree::Printer.new
      # errors = Syntax.new.parse(text: params[:text], visitor: printer, ignore_actions: true)
      # [errors, true]
      interpreter = Interpreter.new(params[:interpretation] || {})
      errors = Syntax.parse(text: params[:text], visitor: interpreter)
      [errors, interpreter.values.pop]
    end

  end

end

require 'mpf/external/parse_tree'
require 'mpf/external/logic/propositional'

module MPF::External::Logic::Predicate

  module Syntax

    include MPF::External::Logic::Propositional::Syntax

  end

  class Interpreter < MPF::External::Logic::Propositional::Interpreter

    def initialize(interpretation)
      super(interpretation)
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

end
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

require 'lang_bench/logic/proposition_logic'

module LangBench
  module Logic
    module PredicateLogic
      module Syntax
        include Logic::PropositionLogic::Syntax
      end

      class Interpreter < PropositionLogic::Interpreter

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
end

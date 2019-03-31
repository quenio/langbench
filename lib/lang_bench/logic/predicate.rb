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

require 'lang_bench/logic/symbol'
require 'lang_bench/logic/formula'

module LangBench
  module Logic
    class Predicate < Formula
      attr_accessor :symbol, :terms

      def initialize(params = {})
        @symbol = params[:symbol]
        @terms = params[:terms]
      ensure
        valid_symbol
        valid_terms
      end

      private

      def valid_symbol
        return if @symbol.is_a? Symbol

        raise "Predicate#symbol must be instance of Symbol but found: #{@symbol.inspect}"
      end

      def valid_terms
        return if @terms.all? { |t| t.is_a? Term }

        raise "Predicate#terms must be instance of Term but found: #{@terms.inspect}"
      end
    end
  end
end

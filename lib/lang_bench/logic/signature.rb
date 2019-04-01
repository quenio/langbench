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
    class Signature
      attr_reader :function_symbols, :predicate_symbols, :arity

      def initialize(params = {})
        @function_symbols = params[:function_symbols].to_set
        @predicate_symbols = params[:predicate_symbols].to_set
        @arity = params[:arity].to_h
      ensure
        valid_function_symbols
        valid_predicate_symbols
        valid_arity_keys
        valid_arity_values
      end

      private

      def valid_function_symbols
        return if @function_symbols.all? { |s| s.is_a? Symbol }

        raise "Signature#function_symbols must be instance of Symbol but found: #{@function_symbols.inspect}"
      end

      def valid_predicate_symbols
        return if @predicate_symbols.all? { |s| s.is_a? Symbol }

        raise "Signature#predicate_symbols must be instance of Symbol but found: #{@predicate_symbols.inspect}"
      end

      def valid_arity_keys
        return if @arity.keys.all? do |k|
          @function_symbols.include? k or @predicate_symbols.include? k
        end

        raise "arity.keys should have function/predicate symbols but found: #{@arity.keys.inspect}"
      end

      def valid_arity_values
        return if @arity.values.all? do |v|
          v.is_a? Integer and v.positive?
        end

        raise "arity.values should have positive integers but found: #{@arity.values.inspect}"
      end
    end
  end
end
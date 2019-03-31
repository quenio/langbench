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
      attr_reader :functions, :relations, :arity

      def initialize(params = {})
        @functions = params[:functions].to_set
        @relations = params[:relations].to_set
        @arity = params[:arity].to_h
      ensure
        valid_arity_keys
        valid_arity_values
      end

      def valid_arity_keys
        return if @arity.keys.all? { |k| @functions.include? k or @relations.include? k }

        raise "arity.keys should have functions or relations but found: #{@arity.keys.inspect}"
      end

      def valid_arity_values
        return if @arity.values.all? { |v| v.is_a? Integer and v.positive? }

        raise "arity.values should have positive integers but found: #{@arity.values.inspect}"
      end
    end
  end
end
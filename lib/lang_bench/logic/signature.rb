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

require 'lang_bench/model/object'

module LangBench
  module Logic
    class Signature < Model::Object
      attr_accessor :function_symbols, :predicate_symbols, :arity

      validates :function_symbols, presence: true, type: Set, item_type: Symbol
      validates :predicate_symbols, presence: true, type: Set, item_type: Symbol
      validates :arity, presence: true

      validate do
        errors.add(:arity, :arity_keys) unless arity_keys_valid?
        errors.add(:arity, :arity_values) unless arity_values_valid?
      end

      private

      def arity_keys_valid?
        arity&.keys&.all? do |k|
          @function_symbols.include? k or @predicate_symbols.include? k
        end
      end

      def arity_values_valid?
        arity&.values&.all? do |v|
          v.is_a? Integer and v.positive?
        end
      end
    end
  end
end
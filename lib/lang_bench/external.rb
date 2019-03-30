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

require 'lang_bench/text/tokenizer'
require 'lang_bench/text/parser'

module LangBench
  module External
    module Syntax
      def self.included(mod)
        mod.extend self
      end

      attr_accessor :skip_regex
      attr_accessor :token_rules
      attr_accessor :grammar_rules
      attr_accessor :token_rules
      attr_accessor :pre_actions
      attr_accessor :post_actions

      def skip(params = {})
        @skip_regex = params[:regex]
      end

      def tokens(rules = {})
        @token_rules ||= {}
        @token_rules = rules.dup.merge(@token_rules)
      end

      def grammar(rules = {})
        @grammar_rules ||= {}
        @grammar_rules = @grammar_rules.merge(rules)
      end

      def before(rule_name, &block)
        (@pre_actions ||= {})[rule_name] = block
      end

      def after(rule_name, &block)
        (@post_actions ||= {})[rule_name] = block
      end

      def parse(options = {})
        tokenizer = Text::Tokenizer.new(
          skip: skip_regex,
          rules: token_rules
        )
        parser = Text::Parser.new(
          tokenizer: tokenizer,
          grammar: grammar_rules,
          visitor: options[:visitor],
          pre_actions: pre_actions,
          post_actions: post_actions,
          ignore_actions: options[:ignore_actions]
        )
        parser.parse(options[:text])
      end
    end
  end
end


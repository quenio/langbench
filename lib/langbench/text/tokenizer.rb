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

module Langbench
  module Text
    class Tokenizer
      attr_accessor :rules

      def initialize(options = {})
        @skip = options[:skip]
        @rules = options[:rules] || {}
      end

      def tokenize(text)
        text = text.dup
        tokens = []
        skip!(text)
        until text.empty?
          token = next!(text)
          tokens.push(token) if token
          skip!(text) if text
        end
        tokens
      end

      def skip!(text)
        substr = text[@skip] if @skip
        text.sub!(substr, '') if substr and text.start_with?(substr)
      end

      def next!(text)
        token = next_token(text)
        if not token or not text.start_with? token.text
          token = Token.new(char: text[0]) unless text.empty?
        end
        text.sub! token.text, '' if token
        token
      end

      def next_token(text)
        raise "Method requires text but found: #{text.inspect}" unless text.is_a? String
        raise "Method requires defined rules but found: #{@rules.inspect}" unless @rules

        rules = @rules.dup
        rule = rules.shift
        token = nil
        while rule and (not token or not text.start_with? token)
          unless rule[1].is_a? Regexp or rule[1].is_a? String
            raise "Method requires text/regex rule but found: #{rule.inspect}"
          end

          token = text[rule[1]]
          category = rule[0]
          rule = rules.shift
        end
        Token.new(category => token) if token
      end

    end
  end
end

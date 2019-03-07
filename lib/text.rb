module MPF

  module Text

    module Renderer

      attr_reader :text

      def init_text_rendering
        @text = ''
      end

      def print(value)
        @text << value
      end

    end

    module Printer

      def init_indentation
        @indent = ''
        @indent_next = true
        @line_changed = [false]
      end

      def indent_print(value)
        print @indent_next ? "\n#{@indent}#{value}" : value
      end

      def indent
        @indent += '  '
      end

      def unindent
        @indent.chomp!('  ')
      end

      def inline
        @indent_next = false
      end

      def enter_section
        @line_changed.push(@indent_next)
      end

      def exit_section
        if @indent_next
          @line_changed.pop
        else
          @indent_next = @line_changed.pop
        end
      end

    end

    class Token

      attr_reader :category
      attr_reader :text

      def initialize(options = {})
        @category = options.first[0]
        @text = options.first[1]
      end

      def raw
        { @category => @text }
      end

      def ==(other)
        return false unless other.is_a? Token
        return true if other.equal? self

        @category == other.category and @text == other.text
      end

      def hash
        (category.to_s + text.to_s).hash
      end

    end

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

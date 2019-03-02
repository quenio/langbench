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

  class Tokenizer

    attr_accessor :skip
    attr_accessor :rules

    def initialize(options = {})
      @skip = options[:skip]
      @rules = options[:rules]
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
      substr = text[@skip]
      substr ? (text.sub! substr, '') : text
    end

    def next!(text)
      token = next_token(text)
      if not token or not text.start_with? token.values[0]
        token = { char: text[0] } unless text.empty?
      end
      text.sub! token.values[0], '' if token
      token
    end

    def next_token(text)
      rules = @rules.dup
      rule = rules.shift
      token = nil
      while rule and (not token or not text.start_with? token)
        token = text[rule[1]]
        id = rule[0]
        rule = rules.shift
      end
      { id => token } if token
    end

  end

end
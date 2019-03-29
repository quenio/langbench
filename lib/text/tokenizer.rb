class Text::Tokenizer

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

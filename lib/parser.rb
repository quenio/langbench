class Parser

  attr_reader :grammar

  def initialize(options = {})
    @grammar = options[:grammar]
  end

  def parse(tokens)
    rule = @grammar.first
    seq = right_term_of(rule).dup # sequence of first rule
    stream = tokens.dup
    until stream.empty?
      token, *stream = stream
      term, *seq = next_term(seq)
      while @grammar[term]
        term, *rest = @grammar[term]
        seq = rest + seq
      end
      return [{ unrecognized: text_of(token) }] unless term
      return [{ missing: term }] unless token == { char: term } or category_of(token) == term
    end
    term = next_term(seq)&.first
    term ? [{ missing: term }] : []
  end

  private

  def next_term(seq)
    term, *seq = seq
    while @grammar[term]
      term, *rest = @grammar[term]
      seq = rest + seq
    end
    term ? seq.unshift(term) : seq
  end

  def left_term_of(rule)
    rule[0]
  end

  def right_term_of(rule)
    rule[1]
  end

  def category_of(token)
    token.first[0]
  end

  def text_of(token)
    token.first[1]
  end
end


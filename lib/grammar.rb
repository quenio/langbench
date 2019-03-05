module MPF

  class Grammar

    class Rule

      attr_reader :grammar
      attr_reader :name
      attr_reader :terms

      def initialize(grammar, name, terms)
        @grammar = grammar
        @name = name
        @terms = [terms].flat_map { |t| t }.map { |t| Term.new(self, t) }
      end

      def method_name
        "#{name}_rule"
      end

      def specialize_terms
        @terms = @terms.map(&:specialized)
      end

    end

    class Term

      attr_reader :parent_rule

      def initialize(parent_rule, term)
        @parent_rule = parent_rule
        @term = term
      end

      def grammar
        parent_rule.grammar
      end

      def def_rule
        grammar.def_rule_of(self)
      end

      def def_terms
        grammar.def_rule_of(self).terms
      end

      def non_terminal?
        @term.is_a? Symbol and def_rule
      end

      def terminal?
        @term.is_a? String
      end

      def optional?
        @term.is_a? Symbol and @term.to_s.end_with? '?', '*'
      end

      def multiple?
        @term.is_a? Symbol and @term.to_s.end_with? '+', '*'
      end

      def alternative?
        @term.is_a? Hash and alternatives
      end

      def alternatives
        @term[:any]&.map { |t| Term.new(parent_rule, t).specialized }
      end

      def regex?
        return false unless non_terminal?

        term = def_terms
        term = term[0].raw
        term = term[:regex] if term.is_a? Hash
        term.is_a? Regexp
      end

      def regex
        term = def_terms
        term = term[0].raw
        if term.is_a? Regexp
          term
        else
          term[:regex]
        end
      end

      def firsts
        term = self
        term, *_rest = term.def_terms while term.non_terminal?
        if term.alternative?
          term.alternatives.flat_map(&:firsts)
        elsif term.raw.is_a? Hash
          term.raw[:firsts] || term.raw[:regex]
        elsif term.raw.is_a? Regexp
          term.raw
        else
          term
        end
      end

      def raw
        if @term.is_a? Symbol
          @term[/\A(\w+)/].to_sym
        else
          @term
        end
      end

      def specialized
        specialized_class.new(@parent_rule, @term)
      end

      def specialized_class
        if non_terminal?
          NonTerminal
        elsif terminal?
          Terminal
        else
          Term
        end
      end

    end

    class Terminal < Term

      def match?(token)
        token.raw == { char: raw }
      end

    end

    class NonTerminal < Term

      def match?(token)
        token.category == raw
      end

    end

    def initialize(rules)
      @rule_array = rules.map { |rule| Rule.new(self, *rule) }
      @rule_hash = @rule_array.map { |rule| [rule.name, rule] }.to_h
      @rule_array.each(&:specialize_terms)
    end

    def start_rule
      @rule_array.first
    end

    def def_rule_of(term)
      @rule_hash[term.raw]
    end

  end


end


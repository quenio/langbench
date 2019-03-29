module LangBench
  module Internal
    class Syntax
      attr_reader :visitor

      def self.evaluate(options = {}, &source_code)
        new(options).instance_eval &source_code
      end

      private

      def initialize(options = {})
        @visitor = options[:visitor]
      end
    end
  end
end

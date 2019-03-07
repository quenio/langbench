module MPF

  module Meta

    module Visitor

      def enter_node(_name, _attributes = {}, &_block)
        raise 'Not implemented.'
      end

      def exit_node(_name, _attributes = {}, &_block)
        raise 'Not implemented.'
      end

      def visit_content(_value)
        raise 'Not implemented.'
      end

    end

  end

end


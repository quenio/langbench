require 'rspec'
require 'mpf/tree'

module MPF

  module UI

    RSpec.describe 'navigation' do

      def navigation
        Tree.source do
          node(:navigation) do
            node(:item, title: 'Bills')
            node(:item, title: 'Installments')
            node(:item, title: 'Expenses')
            node(:item, title: 'Groceries')
          end
        end
      end

      it 'renders XML' do
        expect(navigation.render(to: :xml).strip).to eq(
          <<~XML.strip
            <navigation>
              <item title="Bills"></item>
              <item title="Installments"></item>
              <item title="Expenses"></item>
              <item title="Groceries"></item>
            </navigation>
          XML
        )
      end

    end

  end

end


require 'rspec'
require 'mpf/tree'

module MPF

  module UI

    module Mobile

      RSpec.describe 'Tab Bar' do

        def tab_bar
          Tree.source do
            node(:tab_bar) do
              node(:tab_bar_item, title: 'Bills')
              node(:tab_bar_item, title: 'Installments')
              node(:tab_bar_item, title: 'Expenses')
              node(:tab_bar_item, title: 'Groceries')
            end
          end
        end

        it 'renders XML' do
          expect(tab_bar.render(to: :xml).strip).to eq(
            <<~XML.strip
              <tab_bar>
                <tab_bar_item title="Bills"></tab_bar_item>
                <tab_bar_item title="Installments"></tab_bar_item>
                <tab_bar_item title="Expenses"></tab_bar_item>
                <tab_bar_item title="Groceries"></tab_bar_item>
              </tab_bar>
            XML
          )
        end

      end

    end

  end

end


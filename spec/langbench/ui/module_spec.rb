require 'rspec'
require 'mpf/ui'

module MPF

  module UI

    RSpec.describe 'module' do

      it 'compiles into target' do
        UI.module(path: 'spec/mpf/ui/example_module').compile
      end

    end

  end

end


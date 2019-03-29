require 'lang/external'

module Lang::Logic

  module Syntax

    include Lang::External::Syntax

    def self.included(mod)
      mod.extend self

      mod.skip /\s*/
      mod.tokens variable: /[a-z][a-z0-9_]*/
    end

  end

end

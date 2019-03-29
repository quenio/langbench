require 'mpf/external'

module MPF::External::Logic

  module Syntax

    include MPF::External::Syntax

    def self.included(mod)
      mod.extend self

      mod.skip /\s*/
      mod.tokens variable: /[a-z][a-z0-9_]*/
    end

  end

end
require 'mpf/external/logic'

module MPF::External::Logic::Propositional

  class Syntax < MPF::External::Logic::Syntax

    skip /\s*/

    tokens proposition_literal: /true|false/,
           proposition_prefix: /not/,
           proposition_infix: /and|or|implies|iif/,
           proposition_variable: /[a-z][a-z0-9_]*/

    grammar proposition: %i[proposition_statement binary_proposition*],
            proposition_statement:
            {
              any: %i[proposition_literal proposition_variable unary_proposition]
            },
            unary_proposition: %i[proposition_prefix proposition],
            binary_proposition: %i[proposition_infix proposition]

  end

end

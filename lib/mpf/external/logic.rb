require 'mpf/external'

module MPF::External::Logic

  class Syntax < MPF::External::Syntax

    # Issue: statement below not seen by subclasses:
    tokens variable: /[a-z][a-z0-9_]*/

  end

end
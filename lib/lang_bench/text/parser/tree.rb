# frozen_string_literal: true

#--
# Copyright (c) 2019 Quenio Cesar Machado dos Santos
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software
# and associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute,
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++
#

module LangBench
  module Text
    class Parser
      module Tree

        module Template

          def opened_node(name, attributes)
            "#{name}{#{attributes_list(attributes)}}"
          end

          def closed_node(name, attributes)
            "/#{name}{#{attributes_list(attributes)}}"
          end

          def inner_content(value)
            value.to_s
          end

          def attributes_list(attributes)
            result = attributes.map { |attrib| "#{attrib[0]}=#{attrib[1].inspect}" }.join(', ')
            result = ' ' + result + ' ' unless result.empty?
            result
          end

        end

        class Printer

          include Meta::Visitor
          include Template
          include Text::Printer

          def initialize
            init_indentation
          end

          def enter_node(name, attributes = {})
            enter_section
            indent_print opened_node(name, attributes)
            indent
          end

          def exit_node(name, attributes = {})
            unindent
            indent_print closed_node(name, attributes)
            exit_section
          end

        end

      end
    end
  end
end

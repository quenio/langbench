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

require 'lang_bench/test'

class ModuleTest < Test
  include LangBench::Text::File

  ROOT = 'test/lang_bench/ui/example_module'

  def root_path
    File.expand_path(ROOT)
  end

  def target_path
    "#{root_path}/target"
  end

  def expected_target_path
    "#{root_path}/expected_target"
  end

  def expected_target_files
    Dir.glob("#{expected_target_path}/**/*")
       .map { |path| File.expand_path(path) }
       .reject { |path| File.directory?(path) }
  end

  def compare_target_files
    expected_target_files.each do |expected_file_path|
      actual_file_path = "#{target_path}#{expected_file_path.sub(expected_target_path, '')}"
      assert File.exist?(actual_file_path)
      assert_equal file(expected_file_path), file(actual_file_path), actual_file_path
    end
  end

  def test_compile
    LangBench::UI.module(path: ROOT).compile
    compare_target_files
  end
end


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

Gem::Specification.new do |spec|
  spec.name          = 'langbench'
  spec.version       = '0.1.0'
  spec.authors       = ['Quenio dos Santos']
  spec.email         = ['queniodossantos@gmail.com']

  spec.summary       = 'LangBench - Ruby-Based Language Workbench'
  spec.description   = 'Use Langbench to create your own languages in Ruby.'
  spec.homepage      = 'https://github.com/quenio/langbench'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.6.0'

  raise 'RubyGems 2.0 or newer is required.' unless spec.respond_to?(:metadata)

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/quenio/langbench'
  spec.metadata['changelog_uri'] = 'https://github.com/quenio/langbench/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # https://github.com/rails/rails/tree/master/activesupport
  spec.add_dependency 'activesupport', '~> 5.2.3'

  # https://bundler.io
  spec.add_development_dependency 'bundler', '~> 2.0'

  # https://github.com/ruby/rake
  spec.add_development_dependency 'rake', '~> 10.0'

  # https://www.rubydoc.info/gems/minitest/5.8.4
  spec.add_development_dependency 'minitest', '~> 5.0'

  # RubyMine Debugger
  spec.add_development_dependency 'debase', '~> 0.2.2'
  spec.add_development_dependency 'ruby-debug-ide', '~> 0.7.0.beta7'

  # https://github.com/rantly-rb/rantly
  # spec.add_development_dependency 'rantly', '~> 2.0.0'
end

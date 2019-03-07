# bootlang.gemspec
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mpf'

Gem::Specification.new do |spec|
  spec.name          = 'mpf'
  spec.version       = MPF::VERSION
  spec.authors       = ['Quenio dos Santos']
  spec.email         = ['queniodossantos@gmail.com']

  spec.summary       = 'MPF - Metaprogramming Framework'
  spec.description   = 'Use MPF to create your own languages.'
  spec.homepage      = 'https://github.com/quenio/mpf'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.6.0'

  raise 'RubyGems 2.0 or newer is required.' unless spec.respond_to?(:metadata)

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/quenio/mpf'
  spec.metadata['changelog_uri'] = 'https://github.com/quenio/mpf/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  # RubyMine Debugger
  spec.add_development_dependency 'debase', '~> 0.2.2'
  spec.add_development_dependency 'ruby-debug-ide', '~> 0.7.0.beta7'

  # https://github.com/rantly-rb/rantly
  spec.add_development_dependency 'rantly', '~> 2.0.0'
end

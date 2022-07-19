lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'methodfinder/version'

Gem::Specification.new do |spec|
  spec.name        = 'methodfinder'
  spec.version     = MethodFinder::VERSION
  spec.authors     = ['Michael Kohl']
  spec.email       = ['citizen428@gmail.com']

  spec.summary     = 'A Smalltalk-like Method Finder for Ruby'
  spec.description = 'A Smalltalk-like Method Finder for Ruby with some extra features'
  spec.homepage    = 'https://sr.ht/~citizen428/methodfinder/'
  spec.license     = 'MIT'

  spec.metadata = {
    'bug_tracker_uri' => 'https://todo.sr.ht/~citizen428/methodfinder',
    'source_code_uri' => 'https://git.sr.ht/~citizen428/methodfinder/tree',
    'mailing_list_uri' => 'https://lists.sr.ht/~citizen428/public-inbox',
    'wiki_uri' => 'https://man.sr.ht/~citizen428/MethodFinder/'
  }

  spec.files = `git ls-files -z *.md LICENSE.txt lib`.split("\0")
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.6'

  spec.add_development_dependency 'bundler', '~> 2.3'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rdoc', '~> 6.3'
  spec.add_development_dependency 'rubocop', '~> 1.22'
end

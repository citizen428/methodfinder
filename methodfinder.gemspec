
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'methodfinder/version'

Gem::Specification.new do |spec|
  spec.name          = 'methodfinder'
  spec.version       = MethodFinder::VERSION
  spec.authors       = ['Michael Kohl']
  spec.email         = ['citizen428@gmail.com']

  spec.summary       = 'A Smalltalk-like Method Finder for Ruby'
  spec.description   = 'A Smalltalk-like Method Finder for Ruby with some extra features'
  spec.homepage      = 'http://citizen428.github.com/methodfinder/'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z *.md LICENSE.txt lib`.split("\0")
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rdoc', '~> 6.0'
end

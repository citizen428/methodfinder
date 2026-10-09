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
  spec.homepage    = 'https://github.com/citizen428/methodfinder'
  spec.license     = 'MIT'

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/citizen428/methodfinder/issues',
    'source_code_uri' => 'https://github.com/citizen428/methodfinder',
    'wiki_uri' => 'https://github.com/citizen428/methodfinder/wiki',
    'rubygems_mfa_required' => 'true'
  }

  spec.files = Dir['*.md', 'LICENSE.txt', 'lib/**/*', 'sig/**/*']
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 3.3'
end

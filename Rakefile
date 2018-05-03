# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rdoc/task'
require 'rake/testtask'

Rake::RDocTask.new do |rd|
  rd.rdoc_dir = 'doc/'
  rd.main = "README.md"
  rd.rdoc_files.include("README.md", "lib/**/*.rb")
  rd.title = 'MethodFinder'

  rd.options << '--line-numbers'
  rd.options << '--all'
end

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task default: :test

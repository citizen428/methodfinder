# frozen_string_literal: true

require 'rake/testtask'
require 'rdoc/task'
require 'fileutils'

GEMSPEC = 'methodfinder.gemspec'

Rake::TestTask.new do |t|
  t.pattern = 'test/test_*.rb'
end

Rake::RDocTask.new do |rd|
  rd.rdoc_dir = 'doc/'
  rd.main = "README.md"
  rd.rdoc_files.include("README.md", "lib/**/*.rb")
  rd.title = 'MethodFinder'

  rd.options << '--line-numbers'
  rd.options << '--all'
end

def gemspec
  @gemspec ||= eval(File.read(GEMSPEC), binding, GEMSPEC)
end

namespace :gem do
  desc "Build the gem"
  task :build => :rerdoc do
    sh "gem build #{GEMSPEC}"
    FileUtils.mkdir_p 'pkg'
    FileUtils.mv "#{gemspec.name}-#{gemspec.version}.gem", 'pkg'
  end

  desc "Install the gem locally"
  task :install => :build do
    sh %{gem install pkg/#{gemspec.name}-#{gemspec.version}.gem}
  end
end

task :default => [:test]

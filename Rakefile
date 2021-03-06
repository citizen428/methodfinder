# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'github_changelog_generator/task'
require 'rake/testtask'
require 'rdoc/task'

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

namespace :changelog do
  # update (regenerate) the changelog.
  # uses $CHANGELOG_GITHUB_TOKEN if defined e.g.:
  #
  #   $ CHANGELOG_GITHUB_TOKEN=abc123 bundler exec rake changelog
  GitHubChangelogGenerator::RakeTask.new :generate do |config|
    config.user = 'citizen428'
    config.project = 'methodfinder'
    config.header = '# Changelog'
  end

  # remove the "generated by..." footer
  task :fixup => 'CHANGELOG.md' do |t|
    temp = "#{t.source}.tmp"

    if system("tail -n -1 #{t.source} | grep -iq 'generated by'")
      sh "head -n -3 #{t.source} > #{temp} && mv #{temp} #{t.source}"
    end
  end
end

task changelog: %w[changelog:generate changelog:fixup]
task build: %i[test changelog]
task default: :test

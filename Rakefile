require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Run the brain_buster spec suite.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'spec/**/*_spec.rb'
  t.verbose = true
end

desc 'Generate documentation for the brain_buster plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'BrainBuster'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  gem "ianwhite-garlic"
  require 'garlic/tasks'
rescue LoadError => e
  puts "Garlic not available for testing against multiple versions of Rails.  To install: "
  puts "gem install ianwhite-garlic --source=http://gems.github.com"
  exit(1)
end

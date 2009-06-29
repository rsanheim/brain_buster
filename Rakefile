require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

begin 
  gem "spicycode-micronaut"
  require 'micronaut/rake_task'
  
  Micronaut::RakeTask.new(:examples) do |examples|
    examples.pattern = 'examples/**/*_example.rb'
    examples.ruby_opts << '-Ilib -Iexamples'
  end

  Micronaut::RakeTask.new(:rcov) do |examples|
    examples.pattern = 'examples/**/*_example.rb'
    examples.rcov_opts = %[-Ilib -Iexamples --exclude "gems/*,/Library/Ruby/*,config/*" --text-summary  --sort coverage]
    examples.rcov = true
  end

  task :default => 'rcov'
rescue LoadError
  puts "Micronaut not available to run tests.  Install it with: sudo gem install spicycode-micronaut -s http://gems.github.com"
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

Gem::Specification.new do |s|
  s.name = "brain_buster"
  s.version = "0.8.3"
  s.date = "2009-09-28"
  s.summary = "A Logic Captcha For Rails"
  s.email = ""
  s.homepage = "http://github.com/rsanheim/brain_buster"
  s.description = "BrainBuster is a logic captcha for Rails. A logic captcha attempts to detect automated responses (ie spambots) by asking a simple question, such as a word puzzle or math question."
  s.has_rdoc = false
  s.authors = ["Rob Sanheim"]
  s.files = [
    "README.markdown", "Rakefile", "LICENSE", "garlic.rb",

    "assets/stylesheets/captcha.css",

    "examples/lib/brain_buster_example.rb", "examples/lib/brain_buster_functional_example.rb", "examples/lib/humane_integer_example.rb",

    "examples/views/new.html.erb", "examples/example_helper.rb",
    
    "lib/brain_buster.rb", "lib/brain_buster_system.rb", "lib/humane_integer.rb",
    
    "generators/brain_buster_migration/templates/migration.rb", "generators/brain_buster_migration/brain_buster_migration_generator.rb", "generators/brain_buster_migration/USAGE",

    "views/brain_busters/show.html.erb", "views/brain_busters/_captcha.html.erb", "views/brain_busters/_captcha_footer.html.erb"
  ]

end
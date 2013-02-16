$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "tracks_attributes/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "tracks_attributes"
  s.version     = TracksAttributes::VERSION
  s.authors     = ["Leo O'Donnell"]
  s.email       = ["leopold.odonnell@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of TracksAttributes."
  s.description = "TODO: Description of TracksAttributes."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.11"

  s.add_development_dependency "sqlite3"
end

$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "tracks_attributes/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "tracks-attributes"
  s.version     = TracksAttributes::VERSION
  s.authors     = ["Leo O'Donnell"]
  s.email       = ["leopold.odonnell@gmail.com"]
  s.homepage    = "https://github.com/leopoldodonnell/tracks-attributes"
  s.summary     = "TracksAttributes adds the ability to track ActiveRecord and Object level attributes."
  s.description = "Sometimes you just need to know what your accessors are at runtime, like when you're writing a controller that
  needs to return JSON or XML..."
  s.has_rdoc    = 'yard'

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2"

  s.add_development_dependency "sqlite3"
end

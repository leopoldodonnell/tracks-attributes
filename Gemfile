source "http://rubygems.org"

# Declare your gem's dependencies in tracks_attributes.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# jquery-rails is used by the dummy application
gem "jquery-rails"

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

gem "rspec-rails", :group => [:test, :development]

group :development do
  gem 'yard'
  gem 'growl'
  gem 'ruby_gntp'
  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-yard' unless RUBY_VERSION =~ /1\.8.*/
  gem 'redcarpet', "~>2.0"
  gem 'github-markup'
end

group :test do
  gem "rake"
  gem "guard-rspec"
  gem "rb-fsevent"
  gem "activerecord"
  gem "sqlite3"
end
# To use debugger
# gem 'debugger'

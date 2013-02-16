require 'active_record/railtie'
require 'active_support/core_ext'

module TracksAttributes
  class Railtie < Rails::Railtie
    if defined?(ActiveRecord::Base)
      ActiveRecord::Base.send :include, TracksAttributes
    end
  end
end
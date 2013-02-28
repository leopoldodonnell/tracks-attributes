require 'active_record'

FileUtils.mkdir_p("spec/db/")

ActiveRecord::Base.establish_connection(
    :adapter  => "sqlite3",
    :database => "spec/db/db_test.sqlite"
)

RSpec.configure do |config|
  config.order = "random"
end

require 'rubygems'
require 'test/unit'
require 'active_support'
require 'active_support/test_case'

require 'simple_reports'
require 'active_record'
plugin_test_dir = File.dirname(__FILE__)

# Load the Rails environment
# require File.join(plugin_test_dir, '../../../../config/environment')
require 'active_record/fixtures'
databases = YAML::load(IO.read(plugin_test_dir + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(plugin_test_dir + "/debug.log")

# A specific database can be used by setting the DB environment variable
ActiveRecord::Base.establish_connection(databases[ENV['DB'] || 'sqlite3'])

# Load the test schema into the database
load(File.join(plugin_test_dir, 'schema.rb'))

# Load fixtures from the plugin
# Test::Unit::TestCase.fixture_path = File.join(plugin_test_dir, 'fixtures/')

class SimpleCachedTable < Report::Table::Base
  def row_key(row)
    "#{row.data[0]}_#{row.data[1]}"
  end
end
$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.reject! { |e| e.include? 'TextMate' }
ENV['RAILS_ENV'] = 'test' unless ENV['RAILS_ENV']
RAILS_ROOT = File.expand_path(File.join(File.dirname(__FILE__), *%w[.. ..]))

require 'active_support'
require 'action_controller'
require 'action_controller/test_process'
require 'active_record'

require "mocha"
require 'micronaut'
require 'micronaut-rails'

require 'mocha'
require 'log_buddy'

LogBuddy.init
require File.join(File.dirname(__FILE__), *%w[.. init])

LOG_FILE_NAME = File.expand_path(File.join(File.dirname(__FILE__), "tmp", "test.log"))
DATABASE = File.expand_path(File.join(File.dirname(__FILE__), "tmp", "brain_buster.sqlite3"))
 
def logger
  @logger ||= Logger.new(LOG_FILE_NAME)
end

Column = ActiveRecord::ConnectionAdapters::Column

# allow getting a BrainBuster model without hitting the database
def stub_brain_buster(attributes = {})
  BrainBuster.stubs(:columns).returns(
            [Column.new("question", nil, "string", false), 
             Column.new("answer", nil, "string", false)])
  @brain_buster_stub = BrainBuster.new(attributes)
end

def default_stub
  stub_brain_buster(:question => "What is 2 + 2 ?", :answer => "4")
end

def stub_default_brain_buster
  BrainBuster.stubs(:find_random_or_previous).returns(default_stub)
  default_stub
end

def setup_database
  gem 'sqlite3-ruby'

  ActiveRecord::Base.logger = Logger.new(LOG_FILE_NAME)
  ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => DATABASE)
  ActiveRecord::Migration.verbose = false

  ActiveRecord::Schema.define do
    create_table :brain_busters, :force => true do |t|
      t.column :question, :string
      t.column :answer, :string
    end
  end
end

def teardown_database
  FileUtils.rm DATABASE
end

Micronaut.configure do |config|
  config.enable_controller_support :behaviour => { :describes => lambda { |dt| dt < ::ActionController::Base } }
  config.mock_with :mocha
  config.formatter = :documentation
  config.color_enabled = true
  config.filter_run :options => { :focused => true }
end

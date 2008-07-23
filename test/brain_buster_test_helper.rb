$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.reject! { |e| e.include? 'TextMate' }
ENV['RAILS_ENV'] = 'test' unless ENV['RAILS_ENV']
require 'test/unit'

begin
  require 'rubygems'
  gem 'test-spec', '>= 0.3.0'
  gem 'mocha', '>= 0.4.0'
  gem "log_buddy"
  
  require 'mocha'
  require 'test/spec'
  require 'log_buddy'
  require 'active_support'
  require 'action_controller'
  require 'action_controller/test_process'
  require 'active_record'
rescue LoadError => e
  puts '=> The BrainBuster test suite depends on the following gems: mocha 0.4+, test-spec 0.3+, active_support, and action_controller.'
  puts e.backtrace
end

LogBuddy.init
require File.dirname(__FILE__) + '/../init'

module BrainBusterTestHelper
  BAR = "=" * 80
  LOG_FILE_NAME = File.expand_path(File.join(File.dirname(__FILE__), "test.log"))
   
  def self.included(base)
    base.before { log_spec }
  end
  
  def logger
    @logger ||= Logger.new(LOG_FILE_NAME)
  end
  
  def log_spec
    logger.debug("\n" << BAR << "\n#{name}\n" << BAR)
  end
  
  Column = ActiveRecord::ConnectionAdapters::Column
  
  # allow getting a BrainBuster model without hitting the database
  def stub_brain_buster(attributes = {})
    BrainBuster.stubs(:columns).returns(
              [Column.new("question", nil, "string", false), 
               Column.new("answer", nil, "string", false)])
    @brain_buster_stub ||= BrainBuster.new(attributes)
  end
  
  def default_stub
    stub_brain_buster(:question => "What is 2 + 2 ?", :answer => "4")
  end
  
  def stub_default_brain_buster
    BrainBuster.stubs(:find_random_or_previous).returns(default_stub)
  end
  
end
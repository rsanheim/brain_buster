$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.reject! { |e| e.include? 'TextMate' }
ENV['RAILS_ENV'] = 'test' unless ENV['RAILS_ENV']
require 'test/unit'

begin
  require 'rubygems'
  require 'mocha'
  require 'test/spec'
  require 'active_support'
  require 'action_controller'
  require 'action_controller/test_process'
  require 'active_record'
  gem 'test-spec', '>= 0.3.0'
  gem 'mocha', '>= 0.4.0'
rescue LoadError => e
  puts '=> The BrainBuster test suite depends on the following gems: mocha 0.4+, test-spec 0.3+, active_support, and action_controller.'
  puts e.backtrace
end

require File.dirname(__FILE__) + '/../init'

module BrainBusterTestHelper
  BAR = "=" * 80
  
  def logger
    log_file_name = File.expand_path(File.join(File.dirname(__FILE__), "test.log"))
    @logger ||= Logger.new(log_file_name)
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
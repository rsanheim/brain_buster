require File.join(File.dirname(__FILE__), *%w[.. example_helper])
require 'micronaut-rails'

ActionController::Routing::Routes.draw { |map| map.connect ':controller/:action/:id' }

# Fake controller so we can test BrainBuster functionally
class PagesController < ActionController::Base
  self.append_view_path File.expand_path(File.join(File.dirname(__FILE__), "views"))
  # hack the plugin view path onto the controller
  self.append_view_path File.expand_path(File.join(File.dirname(__FILE__), "..", "views", "brain_busters"))
  
  before_filter :create_brain_buster, :only => [:new]
  before_filter :validate_brain_buster, :only => [:create]

  def new
    render :template => "/new" 
  end
  
  def create
    render :text => "Success!"
  end
  
  def rescue_action(e) 
    raise e 
  end
  
end

describe PagesController do

  before(:all) { setup_database }
  after(:all) { teardown_database }
  
  before(:each) { controller.brain_buster_salt = [Array.new(32){rand(256).chr}.join].pack("m").chomp }
  
  describe "configuration" do

    it "should add the plugin view path to the view path" do
      plugin_view_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "views", "brain_busters"))
      controller.class.view_paths.should include(plugin_view_path)
    end

    it "should raise an exception if the salt doesnt get set to something" do
      controller.brain_buster_salt = nil
      lambda { get(:new) }.should raise_error(RuntimeError)
    end

    it "should add brain_buster_salt class instance variable method to ActionController::Base" do
      ActionController::Base.should respond_to(:brain_buster_salt)
      controller.should respond_to(:brain_buster_salt)
    end

    it "should alias captcha_passed? method" do
      controller.should respond_to(:captcha_passed?)
      controller.should respond_to(:captcha_previously_passed?)
      controller.captcha_passed?.should == controller.captcha_previously_passed?
    end
    
  end

  describe "retrieving brain buster (via new)" do

  
    it "should create captcha for first request" do
      brain_buster = stub("brain_buster")
      BrainBuster.expects(:find).returns(brain_buster)
      get :new
      assigns(:captcha).should == brain_buster
    end

    it "should retrieve same captcha for second request" do
      brain_buster = stub("brain_buster")
      BrainBuster.expects(:find_random_or_previous).with('1').returns(brain_buster)
      get :new, :captcha_id => '1'
      assigns(:captcha).should == brain_buster
    end
    
  end
  
  describe "validate filter" do

    it "should ignore filters if brain buster is not enabled" do
      begin 
        controller.brain_buster_enabled = false
        BrainBuster.expects(:find_random_or_previous).never
        post :create
        response.body.should == "Success!"
      ensure
        controller.brain_buster_enabled = true
      end
    end

    it "should fail validation and halt action if captcha is missing" do
      post :create
      flash[:error].should == controller.brain_buster_failure_message
      response.body.should == controller.brain_buster_failure_message
    end

    it "should indicate previous captcha attempt failed" do 
      stub_default_brain_buster

      post :create, :captcha_id => '1', :captcha_answer => "5"
      flash[:error].should == controller.brain_buster_failure_message
      cookies['captcha_status'].should == BrainBusterSystem.encrypt("failed", controller.brain_buster_salt)
    end

    it "should fail validation and render failure message text if captcha answer is wrong" do 
      stub_default_brain_buster
      post :create, :captcha_id => '1', :captcha_answer => "5"
      flash[:error].should == controller.brain_buster_failure_message
      response.body.should == controller.brain_buster_failure_message
    end

    focused "should validate captcha answer and continue action on success" do
      brain_buster = BrainBuster.create!(:question => "what is 2 + 2?", :answer => "4")
      post :create, :captcha_id => brain_buster.id, :captcha_answer => "Four"
      assigns(:captcha).id.should == brain_buster.id.to_s
      response.body.should == "Success!"
    end

    it "should bypass captcha and never hit the database if it has been previously passed" do
      BrainBuster.expects(:find_random_or_previous).never
      # < Rails 2.3
      # @request.cookies["captcha_status"] = CGI::Cookie.new('captcha_status', BrainBusterSystem.encrypt("passed", @controller.brain_buster_salt))
      # > Rails 2.3
      request.cookies["captcha_status"] = BrainBusterSystem.encrypt("passed", controller.brain_buster_salt)
      post :create
      response.body.should == "Success!"
    end
    
    
  end
end

describe "Validate filter", ActionController::TestCase do
  
  describe "User manually deletes a record from the db", ActionController::TestCase do
    
    pending "successfully returns a record when the requested id does not exist in the db" do
      # BrainBuster.expects(:smart_find).with('123789')
      
      get :new, :captcha_id => '123789'
      assigns(:captcha).should.not.be nil
    end
    
  end
  
end

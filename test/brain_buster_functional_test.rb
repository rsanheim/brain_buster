require File.join(File.dirname(__FILE__), 'spec_helper')

ActionController::Routing::Routes.draw { |map| map.connect ':controller/:action/:id' }

# Fake controller, with a standard show action that where we initialize the captcha,
# and an update action where the captcha has to be verified.
class StubController < ActionController::Base
  self.append_view_path File.expand_path(File.join(File.dirname(__FILE__), "views"))
  # hack the plugin view path onto the controller
  self.append_view_path File.expand_path(File.join(File.dirname(__FILE__), "..", "views", "brain_busters"))
  
  before_filter :create_brain_buster, :only => [:new]
  before_filter :validate_brain_buster, :only => [:create]

  def new() render :template => "/new" end;
  def create() render :text => "Success!"; end;
  def rescue_action(e) raise e end;
  
end

describe "BrainBuster contract", ActionController::TestCase do
  tests StubController
  include BrainBusterTestHelper
  
  before { @controller.brain_buster_enabled = true }
  after  { @controller.brain_buster_salt = [Array.new(32){rand(256).chr}.join].pack("m").chomp }
  
  it "should add the plugin view path to the view path" do
    plugin_view_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "views", "brain_busters"))
    @controller.class.view_paths.should.include plugin_view_path
  end
  
  it "should raise an exception if the salt doesnt get set to something" do
    @controller.brain_buster_salt = nil
    lambda { get(:new) }.should.raise(RuntimeError)
  end
  
  it "should add brain_buster_salt class instance variable method to ActionController::Base" do
    ActionController::Base.should.respond_to(:brain_buster_salt)
    @controller.should.respond_to(:brain_buster_salt)
  end
  
end

describe "Create filter", ActionController::TestCase do
  tests StubController
  include BrainBusterTestHelper
  
  before { @controller.brain_buster_enabled = true }

  it "should alias captcha_passed? method" do
    stub_default_brain_buster
    get :new
    @controller.should.respond_to :captcha_passed?
    @controller.should.respond_to :captcha_previously_passed?    
    @controller.captcha_passed?.should.be @controller.captcha_previously_passed?
  end
  
  it "should create captcha for first request" do
    stub_default_brain_buster
    get :new
    assigns(:captcha).should == default_stub
  end

  it "should retrieve same captcha for second request" do
    BrainBuster.expects(:find_random_or_previous).with('1').returns(default_stub)
    get :new, :captcha_id => '1'
    assigns(:captcha).should == default_stub
  end
  
end

describe "Validate filter", ActionController::TestCase do
  tests StubController
  include BrainBusterTestHelper
  
  before do
    @controller.brain_buster_salt = [Array.new(32){rand(256).chr}.join].pack("m").chomp
    @controller.logger = logger
    @controller.brain_buster_enabled = true
  end
  
  it "should ignore filters if brain buster is not enabled" do
    @controller.brain_buster_enabled = false
    BrainBuster.expects(:find_random_or_previous).never
    post :create
    @response.body.should == "Success!"
  end
  
  it "should fail validation and halt action if captcha is missing" do
    post :create
    flash[:error].should == @controller.brain_buster_failure_message
    @response.body.should == @controller.brain_buster_failure_message
  end
  
  it "should indicate previous captcha attempt failed" do 
    stub_default_brain_buster
    @controller.stubs(:render)
    
    post :create, :captcha_id => '1', :captcha_answer => "5"
    flash[:error].should == @controller.brain_buster_failure_message
    cookies['captcha_status'].should == [BrainBusterSystem.encrypt("failed", @controller.brain_buster_salt)]
  end
  
  it "should fail validation and render failure message text if captcha answer is wrong" do 
    stub_default_brain_buster
    post :create, :captcha_id => '1', :captcha_answer => "5"
    flash[:error].should == @controller.brain_buster_failure_message
    @response.body.should == @controller.brain_buster_failure_message
  end
  
  it "should validate captcha answer and continue action on success" do
    stub_default_brain_buster
    post :create, :captcha_id => '1', :captcha_answer => "Four"
    assigns(:captcha).should == default_stub
    @response.body.should == "Success!"
  end
  
  it "should bypass captcha and never hit the database if it has been previously passed" do
    BrainBuster.expects(:find_random_or_previous).never
    @request.cookies["captcha_status"] = CGI::Cookie.new('captcha_status', BrainBusterSystem.encrypt("passed", @controller.brain_buster_salt))
    
    post :create
    @response.body.should == "Success!"
  end
  
end
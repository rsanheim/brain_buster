require 'digest/sha2'
# Controller level system that actually does the work of creating and validating
# the captcha via filters, and also providing helpers for determining if the captcha was already
# passed or if a previous captcha attempt failed.
#
# This module gets mixed directly into ActionController::Base on init, so you
# can add the filters in whatever controller needs them.
module BrainBusterSystem

  # Expose helper methods and setup config for brain buster
  def self.included(obj)
    obj.helper_method :captcha_passed?, :last_captcha_attempt_failed?
    obj.append_view_path File.expand_path(File.join(RAILS_ROOT, "vendor", "plugins", "brain_buster", "views", "brain_busters"))
    obj.class_eval do
      @@brain_buster_salt ||= "fGr0FXmYQCuW4TiQj/x3yPBTp5lcJ9l6DbO8CUpReDk="
      @@brain_buster_failure_message = "Your captcha answer failed - please try again."
      @@brain_buster_enabled = true
      cattr_accessor :brain_buster_salt, :brain_buster_failure_message, :brain_buster_enabled
    end
  end
  
  # Puts the BrainBuster model onto the controller
  def create_brain_buster
    raise_if_salt_isnt_set
    return true if (captcha_passed? || !brain_buster_enabled)
    debug_brain_buster { "Initializing the brain_buster object."}
    @captcha = find_brain_buster
  end
  
  # Ensure that the answer attempt from the params successfully passes the captcha.
  # If it fails, captcha_failure is called, which by default will place an failure message in the
  # flash and return false (therefore halting the filter chain).
  # If the captcha passes, this just returns true so the filter chain will continue.
  def validate_brain_buster
    raise_if_salt_isnt_set 
    return true if (captcha_passed? || !brain_buster_enabled)
    return captcha_failure unless (params[:captcha_id] && params[:captcha_answer])
      
    captcha = @captcha = find_brain_buster
    is_success = captcha.attempt?(params[:captcha_answer])
    debug_brain_buster { is_success ? "Captcha successfully passed." : "Captcha failed - #{ captcha.inspect }" }
    set_captcha_status(is_success)
    return is_success ? captcha_success : captcha_failure
  end
  
  # Encrypting status strings and the like, as plain text in the cookies is bad for business
  def self.encrypt(str, salt)
    Digest::SHA256.hexdigest("--#{str}--#{salt}--")
  end

  # Has the user already passed the captcha, signifying we can trust them?
  def captcha_passed?
    cookies[:captcha_status] == encrypt("passed")
  end
  alias :captcha_previously_passed? :captcha_passed?
  
  # Determine if the last (and only the last) captcha attempt failed
  def last_captcha_attempt_failed?
    flash[:failed_captcha]
  end
  
  protected
  
  # Callback for when the captcha is passed successfully.
  # Override if you want to store the flag signaling a "safe" user somewhere else, of if you don't want to
  # store it at all (and therefore will challenge users each and every time.)
  def captcha_success
    true
  end
  
  # Callback for when the captcha failed.
  # By default this will set the failure message in the flash, and also render :text with
  # only the failure message!  This is probably not what you want.  Because of the nature of 
  # this plugin, BrainBuster cannot guess where to render or redirect to when a captcha
  # attempt fails.  You should override #render_or_redirect_for_captcha_failure to
  # handle captcha failure yourself.
  def captcha_failure
    set_captcha_failure_message
    render_or_redirect_for_captcha_failure
  end
  
  def render_or_redirect_for_captcha_failure
    render :text => brain_buster_failure_message, :layout => true
  end
  
  def set_captcha_failure_message
    flash[:error] = brain_buster_failure_message
  end
  
  # Save the status of the current captcha, to see if we can bypass the captcha on future requests (if this was successful)
  # or if we need to re-render the same captcha on the next request (for failures).
  def set_captcha_status(is_success)
    status = is_success ? "passed" : "failed"
    flash[:failed_captcha] = params[:captcha_id] unless is_success
    cookies[:captcha_status] = encrypt(status)
  end

  # We raise an exception immediately if the brain_buster_salt isn't set.
  def raise_if_salt_isnt_set
    raise "You have to set the Brain Buster salt to something other then the default." if ActionController::Base.brain_buster_salt.blank?
  end
  
  # Find a captcha either from an id in the params or the flash, or just find a random captcha
  def find_brain_buster
    BrainBuster.find_random_or_previous(params[:captcha_id] || flash[:failed_captcha])
  end
  
  private

  # Log helper
  def debug_brain_buster(&msg)
    logger && logger.debug { msg.call }
  end
  
  def encrypt(str)
    BrainBusterSystem.encrypt(str, brain_buster_salt)
  end
  
end
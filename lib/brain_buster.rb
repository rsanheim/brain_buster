require 'humane_integer'

 # Simple model to hold sets of questions and answers.
class BrainBuster < ActiveRecord::Base
  VERSION = "0.8.2"

  # Attempt to answer a captcha, returns true if the answer is correct.
  def attempt?(string)
    string = string.strip.downcase
    if answer_is_integer?
      return string == answer || string == HumaneInteger.new(answer.to_i).to_english
    else
      return string == answer.downcase
    end
  end

  def self.find_random_or_previous(id = nil)
    # Buggy code referenced in 
    # http://relevance.lighthouseapp.com/projects/20527/tickets/4-ensure-the-random-id-we-find-is-always-really-in-the-db
    # id.nil? ? self.find(random_id(first_id, count)) : find(id)
    id.nil? ? find(:first, :order => random_function) : self.smart_find(id)
  end

  private

  def self.smart_find(id)
    find(id) || find(:first, :order => random_function) 
  end
  
  # No longer needed with above fix
  # def self.random_id(first_id, count)
  #   Kernel.rand(count) + first_id
  # end

  # return first valid id : no longer needed
  # def self.first_id
  #  @first_id ||= find(:all, :order => "id").first.id
  # end

  def answer_is_integer?
    int_answer = answer.to_i
    (int_answer != 0) || (int_answer == 0 && answer == "0")
  end
end

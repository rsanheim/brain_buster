require 'humane_integer'

 # Simple model to hold sets of questions and answers.
class BrainBuster < ActiveRecord::Base
  VERSION = "0.8.3"

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
    id ? find_specific_or_fallback(id) : find_random
  end

  def self.random_function
    case connection.adapter_name.downcase
      when /sqlite/, /postgres/ then "random()"
      else                           "rand()"
    end
  end

  private
  
  def self.find_random
    find(:first, :order => random_function) 
  end
  
  def self.find_specific_or_fallback(id)
    find(id)
  rescue ActiveRecord::RecordNotFound
    find_random
  end
  
  def answer_is_integer?
    int_answer = answer.to_i
    (int_answer != 0) || (int_answer == 0 && answer == "0")
  end
  
end
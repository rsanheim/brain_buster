require 'humane_integer'

 # Simple model to hold sets of questions and answers.
class BrainBuster < ActiveRecord::Base
  VERSION = "0.8.1"
  PROJECT_HOME = "http://opensource.thinkrelevance.com/wiki/BrainBuster"

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
    id.nil? ? self.find(random_id(first_id, count)) : find(id)
  end

  private

  def self.random_id(first_id, count)
    Kernel.rand(count) + first_id
  end

  # return first valid id
  def self.first_id
    @first_id ||= find(:all, :order => "id").first.id
  end

  def answer_is_integer?
    int_answer = answer.to_i
    (int_answer != 0) || (int_answer == 0 && answer == "0")
  end
end

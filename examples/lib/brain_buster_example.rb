require File.join(File.dirname(__FILE__), *%w[.. example_helper])

describe BrainBuster do
  
  describe "question and answers" do
  
    it "should answer simple math ignoring spacing" do
      two_plus_two.attempt?("4").should == true
      two_plus_two.attempt?(" 4   ").should == true
      two_plus_two.attempt?("3").should == false
    end
  
    it "should be able to use words to answer numerical questions" do 
      ["four", "   four   ", " FoUr ", "  fouR"].each do |answer|
        two_plus_two.attempt?(answer).should == true
      end
    end
  
    it "should handle zeroes" do
      ["0", "zero ", "  zerO  "].each do |answer|
        ten_minus_ten.attempt?(answer).should == true
      end
    end
  
    it "should handle string answers ignoring spacing and case" do
      %w[monday MonDay MONDAY MonDay].push("   MondaY  ").each do |answer|
        day_before_tuesday.attempt?(answer).should == true
      end
    end
  
    it "should ignore case in the answer" do
      stub_brain_buster(:question => "Spell god backwards", :answer => "Dog").attempt?("dog").should == true
      stub_brain_buster(:question => "Spell god backwards", :answer => "Dog").attempt?("DOG").should == true
    end

    # fixtures
    def ten_minus_ten
      stub_brain_buster(:question => "What is ten minus ten?", :answer => "0")
    end
  
    def two_plus_two
      stub_brain_buster(:question => "What is two plus two?", :answer => "4")
    end
  
    def day_before_tuesday
      stub_brain_buster(:question => "What is the day before Tuesday?", :answer => "monday")
    end
  end
  
  
  describe "with real db" do

    before { setup_database }
    after  { teardown_database }
    
    it "finds random" do
      brain_buster = BrainBuster.create!(:question => "What is best in life?", 
        :answer => "To crush your enemies, see them driven before you, and to hear the lamentation of the women.")
      BrainBuster.find_random_or_previous.should == brain_buster.reload
    end
    
    it "finds specific record by id if provided" do
      brain_buster_1 = BrainBuster.create!(:question => "What is best in life?", 
        :answer => "To crush your enemies, see them driven before you, and to hear the lamentation of the women.")
      brain_buster_2 = BrainBuster.create!(:question => "What is 2+2?", :answer => "4").reload
      
      BrainBuster.find_random_or_previous(brain_buster_2.id).should == brain_buster_2
    end
    
    it "falls back to a different record if a specific brain_buster was delete" do
      brain_buster_1 = BrainBuster.create!(:question => "What is best in life?", 
        :answer => "To crush your enemies, see them driven before you, and to hear the lamentation of the women.")
      brain_buster_2 = BrainBuster.create!(:question => "What is 2+2?", :answer => "4")
      brain_buster_2.destroy
      
      BrainBuster.find_random_or_previous(brain_buster_2.id).should == brain_buster_1.reload
    end
    
    
  end
  
end

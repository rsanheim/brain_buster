require File.join(File.dirname(__FILE__), *%w[.. example_helper])

describe HumaneInteger do

  it "should respond to english method" do
    one = HumaneInteger.new(1)
    lambda {
      one.to_english
    }.should_not raise_error
  end
  
  it "should have english words for ints" do
    to_english(1).should == "one"
    to_english(42).should == "forty-two"
    to_english(102).should == "one hundred two"
    to_english(40562).should == "forty thousand five hundred sixty-two"
  end
  
  private
  
  def to_english(int)
    HumaneInteger.new(int).to_english
  end
end

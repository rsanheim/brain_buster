require File.join(File.dirname(__FILE__), 'brain_buster_test_helper')

class HumaneIntegerTest < Test::Unit::TestCase

  def test_should_respond_to_english_method
    one = HumaneInteger.new(1)
    assert one.respond_to?(:to_english)
  end
  
  def test_should_have_english_words_for_ints
    assert_equal "one", to_english(1)
    assert_equal "forty-two", to_english(42)
    assert_equal "one hundred two", to_english(102)
    assert_equal "forty thousand five hundred sixty-two", to_english(40562)
  end
  
  private
  
  def to_english(int)
    HumaneInteger.new(int).to_english
  end
end

require File.dirname(__FILE__) + '/../test_helper'

class OccupationTest < Test::Unit::TestCase
  fixtures :occupations

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Occupation, occupations(:programmer)
  end
end

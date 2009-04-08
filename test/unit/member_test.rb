require File.dirname(__FILE__) + '/../test_helper'

class MemberTest < Test::Unit::TestCase
  fixtures :members

  # Replace this with your real tests.
  def test_first_object
    assert_kind_of Member, members(:first_programmer)
    assert_equal "First", members(:first_programmer).first_name
  end
  
  def test_member_name
    test_member = Member.new
    assert_equal nil, test_member.first_name
    
    test_member.first_name = "Fred"
    test_member.last_name = "Jones"
    test_member.email = "fred@jones.com"
    test_member.password = "jones"
    test_member.password_confirmation = "jones"
    assert test_member.save
    assert_equal "Fred", test_member.first_name 
  end
  
end

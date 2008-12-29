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
    assert test_member.save
    assert_equal "Fred", test_member.first_name 
  end
  
  def test_login_good_password
    first = members(:first_programmer)
    member = Member.authenticate(first.email, first.password)
    assert_equal first.email, member.email
  end
  
  def test_login_bad_password
    first = members(:first_programmer)
    member = Member.authenticate(first.email, '')
    assert_nil member
  end
  
end

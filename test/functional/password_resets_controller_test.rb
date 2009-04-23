require 'test_helper'

class PasswordResetsControllerTest < ActionController::TestCase
  def setup
    ActionMailer::Base.deliveries = []
  end
  
  # Replace this with your real tests.
  test "can't reset password if you're already logged in" do
    login(members(:first_programmer))
    get :new
    assert_redirected_to root_url
  end
  
  test "can reset password if not logged in" do
    get :new
    assert_template "new"
  end
  
  test "resetting password has no effect with bogus email" do
    post :create, :email => "foo@bar.com"
    assert_equal "No member was found with that email address", flash[:notice]
    assert_template "new"
  end
  
  test "resetting password with legit email sends email" do
    assert_difference("ActionMailer::Base.deliveries.size", 1) do
      post :create, :email => members(:first_programmer).email
      assert ActionMailer::Base.deliveries.first.body.include?(members(:first_programmer).reload.perishable_token)
    end
  end
  
  test "getting edit form with a bad perishable token doesn't work" do
    get :edit, :id => "foo"
    assert flash[:notice].starts_with?("We're sorry")
    assert_redirected_to root_url
  end
  
  test "resetting password with a legit perishable token shows reset password form" do
    members(:first_programmer).reset_perishable_token!
    get :edit, :id => members(:first_programmer).perishable_token
    assert_template "edit"
  end
  
  test "resetting password with bad token doesn't work" do
    put :update, :id => "foo", :member => {:password => "bar", :password_confirmation => "bar"}
    assert flash[:notice].starts_with?("We're sorry")
    assert_redirected_to root_url
  end
  
  test "resetting password with legit token but mismatched passwords fails" do
    members(:first_programmer).reset_perishable_token!
    put :update, :id => members(:first_programmer).perishable_token, :member => {:password => "foo", :password_confirmation => "foobar"}
    assert_template "edit"
  end
  
  test "resetting password with legit token matching passwords works" do
    members(:first_programmer).reset_perishable_token!
    put :update, :id => members(:first_programmer).perishable_token, :member => {:password => "okokok", :password_confirmation => "okokok"}
    assert_equal "Password successfully updated", flash[:notice]
    assert_redirected_to root_url
    assert members(:first_programmer).reload.valid_password?("okokok")
  end
end

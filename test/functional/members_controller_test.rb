require File.dirname(__FILE__) + '/../test_helper'

class MembersControllerTest < ActionController::TestCase

  def test_index
    get :index
    assert_response :success
    assert_template 'list' #rhr, we switched to list for index because of the featured member page being dropped.
  end

#  def test_list
#    get :list
#
#    assert_response :success
#    assert_template 'list'
#
#    assert_not_nil assigns(:members)
#  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:member)
    assert assigns(:member).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:member)
  end

  def test_create
    num_members = Member.count
    Member.any_instance.expects(:spam?).returns(false)
    post :create, :member => {:first_name => "Joe",
                              :last_name => "Schmoe",
                              :email => "joe@schmoe.com",
                              :password => "schmoe",
                              :password_confirmation => "schmoe"}

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_members + 1, Member.count
  end
  
  def test_edit_redirects_to_login
    get :edit, :id => members(:first_programmer).id
    assert_login_needed
  end
  
  def test_cannot_edit_another_user
    login members(:first_programmer)
    
    get :edit, :id => members(:second_programmer).id
    
    assert_equal members(:first_programmer), assigns(:member)
    
  end

  def test_edit_after_login
    login members(:first_programmer)

    get :edit, :id => members(:first_programmer).id

    assert_response :success

    assert_not_nil assigns(:member)
    assert assigns(:member).valid?
  end
  
  def test_update_redirects_to_login
    post :update, :id => members(:first_programmer).id
    
    assert_login_needed
  end
  
  def test_updating_other_user_redirects_to_login
    Member.any_instance.expects(:spam?).returns(false)
    login members(:first_programmer)
    post :update, :member => members(:first_programmer).attributes.merge(:id => members(:second_programmer).id)
    assert_redirected_to :action => "index"

    #insure nothing changed
    assert Member.find(:first, members(:second_programmer).id).email = members(:second_programmer).email
  end

  def test_update_after_login
    login members(:first_programmer)
    Member.any_instance.expects(:spam?).returns(false)
    post :update, :id => members(:first_programmer).id
    
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end
  
  def test_members_by_occupation
    get :members_by_occupation, :id => occupations('programmer').id
    assert_response :success
    assert assigns(:members).size == 2
  end
  
  def test_members_by_occupation_with_invalid_occupation_id
    get :members_by_occupation, :id => 10000
    assert_response :success
    assert assigns(:members).empty?
  end
  
  def test_email_visibility_preference_when_false_and_not_logged_in
    assert_email_not_shown(members(:no_occupation))
  end
  
  def test_email_visibility_preference_when_false_and_logged_in
    login members(:first_programmer)
    assert_email_shown(members(:no_occupation))
  end
  
  def test_email_visibility_preference_when_true
    assert members(:first_programmer).is_email_visible == true
    assert_email_shown(members(:first_programmer))
  end
  
  def test_akismet_integration
    Member.any_instance.expects(:spam?).once.returns(true)
    post :create, :member => {:first_name => "viagra-test",
                              :last_name => "-123",
                              :url => "http://www.comedysportzla.com/mb1/board1/490.shtml",
                              :email => "zane@mail.com",
                              :password => "schmoe",
                              :password_confirmation => "schmoe",
                              :bio => "nice site!"}
    assert assigns(:member).valid?
    #success in this case means the record wasn't created and the user was returned to the new profile form
    assert_response :success
  end
  
  def test_member_with_same_first_and_last_name_not_allowed
    Member.any_instance.expects(:spam?).once.returns(false)
    post :create, :member => {:first_name => "foo",
                              :last_name => "foo",
                              :url => "foo.com",
                              :email => "foo@foo.com",
                              :password => "test",
                              :password_confirmation => "test"}
    assert_response :success
  end
end

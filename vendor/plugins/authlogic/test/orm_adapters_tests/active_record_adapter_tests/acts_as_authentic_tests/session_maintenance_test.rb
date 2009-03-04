require File.dirname(__FILE__) + '/../../../test_helper.rb'

module ORMAdaptersTests
  module ActiveRecordAdapterTests
    module ActsAsAuthenticTests
      class SessionMaintenanceTest < ActiveSupport::TestCase
        def test_login_after_create
          assert User.create(:login => "awesome", :password => "saweet", :password_confirmation => "saweet", :email => "awesome@awesome.com")
          assert UserSession.find
        end

        def test_update_session_after_password_modify
          ben = users(:ben)
          UserSession.create(ben)
          old_session_key = @controller.session["user_credentials"]
          old_cookie_key = @controller.cookies["user_credentials"]
          ben.password = "newpass"
          ben.password_confirmation = "newpass"
          ben.save
          assert @controller.session["user_credentials"]
          assert @controller.cookies["user_credentials"]
          assert_not_equal @controller.session["user_credentials"], old_session_key
          assert_not_equal @controller.cookies["user_credentials"], old_cookie_key
        end

        def test_no_session_update_after_modify
          ben = users(:ben)
          UserSession.create(ben)
          old_session_key = @controller.session["user_credentials"]
          old_cookie_key = @controller.cookies["user_credentials"]
          ben.first_name = "Ben"
          ben.save
          assert_equal @controller.session["user_credentials"], old_session_key
          assert_equal @controller.cookies["user_credentials"], old_cookie_key
        end

        def test_updating_other_user
          ben = users(:ben)
          UserSession.create(ben)
          old_session_key = @controller.session["user_credentials"]
          old_cookie_key = @controller.cookies["user_credentials"]
          zack = users(:zack)
          zack.password = "newpass"
          zack.password_confirmation = "newpass"
          zack.save
          assert_equal @controller.session["user_credentials"], old_session_key
          assert_equal @controller.cookies["user_credentials"], old_cookie_key
        end

        def test_resetting_password_when_logged_out
          ben = users(:ben)
          assert !UserSession.find
          ben.password = "newpass"
          ben.password_confirmation = "newpass"
          ben.save
          assert UserSession.find
          assert_equal ben, UserSession.find.record
        end
      end
    end
  end
end
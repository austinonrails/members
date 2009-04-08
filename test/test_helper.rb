ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'authlogic/testing/test_unit_helpers'
require 'mocha'

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false
  
  fixtures :all

  # Add more helper methods to be used by all tests here...
  
  def assert_login_needed
    assert_response :redirect
    assert_redirected_to :controller => :member_sessions, :action => :new
  end
  
  def login(member)
    set_session_for(member)
  end
  
  def assert_email_not_shown(for_user)
    assert for_user.is_email_visible == false
    get :show, :id => for_user.id
    assert_tag :tag => "div",
               :attributes => { "class" => "member"},
               :descendant => { :tag => "a", :child => /Login/ }
  end
  
  def assert_email_shown(for_user)
    get :show, :id => for_user.id
    assert_tag :tag => "div",
               :attributes => {"class" => "member"},
               :descendant => { :tag => "script", :child => /hivelogic_enkoder/ }
  end
end

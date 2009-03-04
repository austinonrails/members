# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base

  before_filter :prep_sidebar

  protected
  
  def current_member
    @current_member ||= Member.find(session[:user_id])
  end
  helper_method :current_member

  private
  
  def prep_sidebar
    @most_recent_members = Member.find(:all, :order => 'created_at desc', :limit => 5)
	  @occupations = Occupation.find(:all, :order => 'name asc')
  end
end
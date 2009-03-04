# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base

  filter_parameter_logging :password, :password_confirmation
  helper_method :current_member_session, :current_member

  before_filter :prep_sidebar

  protected

  # helper_method :current_member

  private
  
  def prep_sidebar
    @most_recent_members = Member.find(:all, :order => 'created_at desc', :limit => 5)
	  @occupations = Occupation.find(:all, :order => 'name asc')
  end

    def current_member_session
      return @current_member_session if defined?(@current_member_session)
      @current_member_session = MemberSession.find
    end

    def current_member
      return @current_member if defined?(@current_member)
      @current_member = current_member_session && current_member_session.member
    end

    def require_member
      unless current_member
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to new_member_session_url
        return false
      end
    end

    def require_no_member
      if current_member
        store_location
        flash[:notice] = "You must be logged out to access this page"
        redirect_to account_url
        return false
      end
    end

    def store_location
      session[:return_to] = request.request_uri
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end


end
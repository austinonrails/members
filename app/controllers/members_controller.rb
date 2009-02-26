class MembersController < ApplicationController
  
  before_filter :check_authentication, :only => [:edit, :update]
  
  def index
    list
    render :template => "members/list"
  end

  def list
    @members = Member.find(:all).paginate(:page => params[:page], :per_page => 10, :order => "created_at DESC")
  end

  def show
    @member = Member.find(params[:id])
  end

  def new
    @member = Member.new
  end

  def create
    @member = Member.new(params[:member])
    comment = {:author => "#{@member.first_name}#{@member.last_name}",
               :url => @member.url,
               :email => @member.email,
               :body => @member.bio,
               :type => "biography"}
    if (@member.first_name != @member.last_name) && Akismet.comment_check(request, comment) && @member.save
      flash[:notice] = 'Member was successfully created.'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
    @member = Member.find(session[:user_id])
  end

  def update
    @member = Member.find(params[:id])
    if @member.update_attributes(params[:member])
      flash[:notice] = 'Member was successfully updated.'
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end
  
  def members_by_occupation
    begin
      @occupation = Occupation.find(params[:id])
      @members = Member.find(:all, :conditions => ["occupation_id = ?", params[:id]]).paginate(:page => params[:page], :per_page => 10, :order => "created_at DESC")
    rescue
      @members = []
    end
    render :template => 'members/list'
  end
  
  def login
    if request.post?
      @member = Member.authenticate(params[:member][:email], params[:member][:password])
      if @member
        session[:user_id] = @member.id
        flash[:welcome] = "Welcome back, #{@member.first_name}"
        redirect_to :action => "list"
      else
        flash[:notice] = "Login incorrect, please try again."
        @member= Member.new(:email => params[:member][:email])
      end
    end
  end
  
  def logout
    session[:user_id] = nil
    redirect_to home_path
  end
  
  private
  def check_authentication
    redirect_to :action => 'login' unless session[:user_id] and params[:id] == session[:user_id].to_s
  end
end

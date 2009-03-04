class MembersController < ApplicationController
  
  before_filter :require_no_member, :only => [:new, :create]
  before_filter :require_member, :only => [ :edit, :update]

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
    # only allows for member to edit his own profile
    @member = @current_member
  end

  def update
    #always updating the current member
    @member =  @current_member # makes our views "cleaner" and more consistent
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
  
  private

end

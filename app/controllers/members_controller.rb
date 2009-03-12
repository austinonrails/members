class MembersController < ApplicationController

  has_rakismet :only => [ :create, :update ]
  
  before_filter :require_no_member, :only => [:new, :create]
  before_filter :require_member, :only => [ :edit, :update]

  def index
    list
    render :template => "members/list"
  end

  def list
    @members = Member.find(:all).paginate(:page => params[:page], :per_page => 10, :order => "created_at DESC")
    @most_recent_members = Member.find(:all, :order => 'created_at desc', :limit => 5)
    @occupations = Occupation.find(:all, :order => 'name asc')
  end

  def show
    @member = Member.find(params[:id])
  end

  def new
    @member = Member.new
  end

  def create
    @member = Member.new(params[:member])
    if @member.spam? then
      flash[:error] = 'Member not created: profile contains dis-allowed text (re. Akismet)'
      render :action => 'new' and return
    end

    if (@member.first_name != @member.last_name) && @member.save
      flash[:notice] = 'Member was successfully created.'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
    # only allows for member to edit his own profile
    @member = current_member
  end

  def update
    #always updating the current member
    @member = current_member # makes our views "cleaner" and more consistent
    temp_member = Member.new(params[:member])
    if temp_member.spam? then
      flash[:error] = 'Member not updated: profile contains dis-allowed text (re. Akismet)'
      @member = temp_member
      render :action => 'edit' and return
    end
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

  def auto_complete_for_member_full_name
    name = '%' + params[:member][:full_name] + '%'
    @items = Member.find(:all, :conditions => [ "last_name LIKE ? OR first_name LIKE ? OR twitter LIKE ?", name, name, name ], :order => 'last_name ASC', :limit => 10)
    render :inline => "<%= auto_complete_result @items, 'last_name' %>"
  end

  def search
    name = '%' + params[:member][:full_name] + '%'
    @members = Member.find(:all, :conditions => [ "last_name LIKE ? OR first_name LIKE ? OR twitter LIKE ?", name, name, name ]).paginate(:page => params[:page], :per_page => 10, :order => "created_at DESC")
    case @members.length
    when 0 then  render :template => "members/list"
    when 1 then
      @member = @members[0]
      render :template => 'members/show' 
    else
      render :template => 'members/list' 
    end
  end
  
  private

end

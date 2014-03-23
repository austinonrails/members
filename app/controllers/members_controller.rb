class MembersController < ApplicationController

  before_filter :require_no_member, :only => [:new, :create]
  before_filter :require_member, :only => [ :edit, :update]

  def index
    @members = Member.paginate(:page => params[:page], :per_page => 10, :order => "created_at DESC")
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
    @member = Member.new(member_params)
    
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
    
    if @member.update_attributes(member_params)
      flash[:notice] = 'Member was successfully updated.'
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end
  
  def members_by_occupation
    begin
      @occupation = Occupation.find(params[:id])
      @members = Member.paginate(:conditions => ["occupation_id = ?", params[:id]], :page => params[:page], :per_page => 10, :order => "created_at DESC")
    rescue
      @members = [].paginate
    end
    render :index
  end

  def auto_complete_for_member_full_name
    name = '%' + params[:member][:full_name] + '%'
    @members = Member.find(:all, :conditions => [ "last_name LIKE ? OR first_name LIKE ? OR twitter LIKE ?", name, name, name ], :order => 'last_name ASC', :limit => 10)
    render :inline => "<%= member_search_result @members %>"
  end

  def search
    name = params[:member][:full_name].split(' ')
    case name.length
    when 0
      return
    when 1
      first_name = name[0]
      last_name = name[0]
    when 2
      first_name = name[0]
      last_name = name[1]
    else
      last_name = name.last
      first_name = name[0]
    end
    first_name = '%' + first_name + '%'
    last_name = '%' + last_name + '%'
    @members = Member.find(:all, :conditions => [ "last_name LIKE ? OR first_name LIKE ?", last_name, first_name ]).paginate(:page => params[:page], :per_page => 10, :order => "created_at DESC")
    case @members.length
      when 0 then  render :index
      when 1 then
        @member = @members.first
        render :show 
      else
        render :index
    end
  end

  private
  def member_params
    params.require(:member).permit(:first_name, :last_name, :email, :occupation_id, :url, :image, :bio, :twitter, :github)
  end
end

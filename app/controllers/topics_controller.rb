class TopicsController < ApplicationController
  before_filter :require_member, :only => [ :new, :create, :edit, :update, :destroy ]

  helper :members

  def index
    @topics = Topic.find(:all, :order => "interest_count desc").paginate(:page => params[:page], :per_page => 10)
    @most_popular_topics = Topic.find(:all, :order => 'interest_count desc', :limit => 5)
    @most_recent_topics = Topic.find(:all, :order => 'created_at desc', :limit => 5)

    respond_to do |format|
      format.html
    end
  end

  def show
    @topic = Topic.find(params[:id])

    respond_to do |format|
      format.html
    end
  end
  
  def new
    @topic = Topic.new

    respond_to do |format|
      format.html
    end
  end

  def edit
    @topic = Topic.find(params[:id])
  end

  def create
    input_string = fix_string(params[:topic][:name])
    params[:topic][:name] = input_string
    @topic = Topic.find(:first, :conditions => ["name = '#{input_string}'"]) || Topic.new(params[:topic])

    respond_to do |format|
      if @topic.save
        flash[:notice] = 'Topic was successfully created.'
        format.html { redirect_to(@topic) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @topic = Topic.find(params[:id])

    respond_to do |format|
      if @topic.update_attributes(params[:topic])
        flash[:notice] = 'Topic was successfully updated.'
        format.html { redirect_to(@topic) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @topic = Topic.find(params[:id])
    @topic.destroy

    respond_to do |format|
      format.html { redirect_to(topics_url) }
    end
  end
  
  def enthusiasts
    @topic = Topic.find(params[:id])
    @enthusiasts = @topic.enthusiasts.paginate(:page => params[:page], :per_page => 10)
    
    respond_to do |format|
      format.html
    end
  end
  
  def experts
    @topic = Topic.find(params[:id])
    @experts = @topic.experts.paginate(:page => params[:page], :per_page => 10)
    
    respond_to do |format|
      format.html
    end
  end

  def speakers
    @topic = Topic.find(params[:id])
    @speakers = @topic.speakers.paginate(:page => params[:page], :per_page => 10)
    
    respond_to do |format|
      format.html
    end
  end

  def auto_complete_for_topic_name
    input_string = fix_string(params[:topic][:name])
    @items = Topic.find(:all, :conditions => [ "name LIKE ?", '%' + input_string + '%' ], :order => 'name ASC', :limit => 10)
    render :inline => "<%= auto_complete_result @items, 'name' %>"
  end

  def search
    search_string = '%' + fix_string(params[:topic][:name]) + '%'
    @topics = Topic.find(:all, :conditions => [ "name LIKE ?", search_string ]).paginate(:page => params[:page], :per_page => 10)
    @most_popular_topics = Topic.find(:all, :order => 'interest_count desc', :limit => 5)
    @most_recent_topics = Topic.find(:all, :order => 'created_at desc', :limit => 5)
    render :template =>  'topics/index' and return
  end

  def update
    @topic = Topic.find(params[:id])

    respond_to do |format|
      if @topic.update_attributes(params[:topic])
        flash[:notice] = 'Topic was successfully updated.'
        format.html { redirect_to(@topic) }
      else
        format.html { render :action => "edit" }
      end
    end
  end


  private

  #change this to control what can be in a topic string and what cannot be
  def fix_string(input_string)
    input_string.delete! '_'
    input_string.delete! '-'
    input_string.delete! ' '
    input_string.downcase!
    return input_string.singularize
  end

end

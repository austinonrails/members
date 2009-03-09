class TopicsController < ApplicationController
  before_filter :require_member, :only => [ :new, :create, :edit, :update, :destroy ]

  layout "members"

  def index
    @topics = Topic.find(:all).paginate(:page => params[:page], :per_page => 10, :order => "interest_count DESC")

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
    @topic = Topic.new(params[:topic])

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
end

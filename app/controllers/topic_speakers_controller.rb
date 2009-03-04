class TopicSpeakersController < ApplicationController
  layout "members"

  helper :members
  
  def index
    @topic = Topic.find(params[:topic_id])
    @speakers = @topic.speakers.paginate(:page => params[:page], :per_page => 10, :order => "created_at DESC")
    
    respond_to do |format|
      format.html
    end
  end

  def create
    @speaker = TopicSpeaker.new
    @speaker.topic_id = params[:topic_id]
    @speaker.member_id = session[:user_id] # TODO: Let's use some better auth package
    @speaker.save
    
    respond_to do |format|
      format.html { redirect_to topics_path }
    end
  end

  def destroy
    # TODO: Implement
    # @interest = MemberInterest.find(params[:member_interest])
    # @topic = Topic.find(params[:id])
    # @topic.destroy
    # 
    # respond_to do |format|
    #   format.html { redirect_to(topics_url) }
    # end
  end
end

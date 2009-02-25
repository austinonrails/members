class MemberInterestsController < ApplicationController
  layout "members"

  helper :members
  
  def index
    @topic = Topic.find(params[:topic_id])
    @members = @topic.enthusiasts
    
    respond_to do |format|
      format.html
    end
  end

  def create
    @interest = MemberInterest.new
    @interest.topic_id = params[:topic_id]
    @interest.member_id = session[:user_id] # TODO: Let's use some better auth package
    @interest.save
    
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

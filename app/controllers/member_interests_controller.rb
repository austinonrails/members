class MemberInterestsController < ApplicationController
  before_filter :require_member, :only => [ :create ]

  layout "members"

  def index
    @topic = Topic.find(params[:topic_id])
    @members = @topic.enthusiasts
    
    respond_to do |format|
      format.html
    end
  end

  # Create or update
  def create
    @member_interest = MemberInterest.find_or_create_by_topic_id_and_member_id(params[:topic_id], current_member.id)
    @member_interest.attributes = params[:member_interest]
    @member_interest.save
    
    respond_to do |format|
      format.html { redirect_to topics_path }
      format.js
    end
  end

end

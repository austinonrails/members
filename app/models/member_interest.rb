class MemberInterest < ActiveRecord::Base
  belongs_to :member
  belongs_to :topic
  
  validates_presence_of :topic_id, :member_id
  validates_uniqueness_of :topic_id, :scope => [:member_id], :message => "You've already expressed interest in this topic."
  
  before_save :update_interest_count
  
  def update_interest_count
    if self.is_interested_changed?
      self.is_interested? ? self.topic.increment!(:interest_count) : self.topic.decrement!(:interest_count)
    end
  end
  
end

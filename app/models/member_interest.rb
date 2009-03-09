class MemberInterest < ActiveRecord::Base
  belongs_to :member
  belongs_to :topic
  
  validates_presence_of :topic_id, :member_id
  validates_uniqueness_of :topic_id, :scope => [:member_id], :message => "You've already expressed interest in this topic."
  
  before_save :update_interest_counts
  
  def update_interest_counts
    if self.is_interested_changed?
      self.is_interested? ? self.topic.increment!(:interest_count) : self.topic.decrement!(:interest_count)
    end
    if self.is_expert_changed?
      self.is_expert? ? self.topic.increment!(:expert_count) : self.topic.decrement!(:expert_count)
    end
    if self.will_speak_changed?
      self.will_speak? ? self.topic.increment!(:speaker_count) : self.topic.decrement!(:speaker_count)
    end
  end
  
end

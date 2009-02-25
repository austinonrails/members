class MemberInterest < ActiveRecord::Base
  belongs_to :member
  belongs_to :topic, :counter_cache => true
  
  validates_presence_of :topic_id, :member_id
  validates_uniqueness_of :topic_id, :scope => [:member_id], :message => "You've already expressed interest in this topic."
  
  
end

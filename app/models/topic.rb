class Topic < ActiveRecord::Base
  has_many :member_interests
  has_many :enthusiasts, :through => :member_interests, :source => :member, :conditions => {'member_interests.is_interested' => true}
  has_many :experts, :through => :member_interests, :source => :member, :conditions => {'member_interests.is_expert' => true}
  has_many :speakers, :through => :member_interests, :source => :member, :conditions => {'member_interests.will_speak' => true}

  validates_presence_of :name

  attr_accessible :name
  
  def member_interest(member)
    member_interests.find_by_member_id(member.id)
  end
end

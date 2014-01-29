class Topic < ActiveRecord::Base
  has_many :interests
  has_many :members, through: :interests

  before_save :lower_name

  validates_presence_of :name

  def enthusiasts
    self.members.where(member_interests: {is_interested: true})
  end
  
  def experts
    self.members.where(member_interests: {is_expert: true})
  end
  
  def speakers
    self.members.where(member_interests: {will_speak: true})
  end

  def member_interest(member)
    member_interests.find_by_member_id(member.id)
  end

  def lower_name
    self.name = self.name.downcase
  end

end

class Topic < ActiveRecord::Base
  has_many :member_interests
  has_many :enthusiasts, :through => :member_interests, :source => :member
  has_many :topic_speakers
  has_many :speakers, :through => :topic_speakers, :source => :member

  validates_presence_of :name

  attr_accessible :name

  before_save :lower_name

  def lower_name
    self.name = self.name.downcase
  end

end

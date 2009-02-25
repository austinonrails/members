class Topic < ActiveRecord::Base
  has_many :member_interests
  has_many :enthusiasts, :through => :member_interests, :source => :member

  validates_presence_of :name

  attr_accessible :name
end

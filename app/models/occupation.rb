class Occupation < ActiveRecord::Base
  has_many :members
  validates_presence_of :name
  validates_uniqueness_of :name
end

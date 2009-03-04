class Member < ActiveRecord::Base

  #for authlogin plugin
  # using email for the login id
  acts_as_authentic  :login_field => 'email'
  
  belongs_to :occupation
  has_many :member_interests, :dependent => :destroy
  has_many :interests, :through => :member_interests, :source => :topic, :conditions => {'member_interests.is_interested' => true}
  
  begin
    file_column :image, :magick => {:geometry => "100x"}
  rescue Exception
    file_column :image
  end
  
  validates_presence_of :first_name, :last_name, :email, :password
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_uniqueness_of :email
  validates_confirmation_of :password
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def self.authenticate(email, password)
    Member.find(:first, :conditions => ["email = ? AND password = ?", email, password])
  end

  def interested_in?(topic)
    self.interests.exists?(topic)
  end
  
  def will_speak_on?(topic)
    self.presentations.exists?(topic)
  end
end

class Member < ActiveRecord::Base

  # for authlogin plugin
  # using email for the login id
  acts_as_authentic  do |c|
   c.login_field  'email'
  end


  has_many :interests
  has_many :topics, through: :interests

  belongs_to :occupation

  def spam?
    #probably defined in raskimet which is currently commented out
    false
  end
 ## comment out images for now 
  #begin
  #  file_column :image, :magick => {:geometry => "100x"}
  #rescue Exception
  #  file_column :image
  #end
  
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, email: true, presence: true, uniqueness: true 

  
  def full_name
    "#{first_name} #{last_name}"
  end

  def interested_in?(topic)
    self.interests.exists?(topic)
  end
  
  def will_speak_on?(topic)
    self.presentations.exists?(topic)
  end
  
  def send_password_reset
    reset_perishable_token!   
    PasswordResetMailer.send_reset(self).deliver 
  end
end

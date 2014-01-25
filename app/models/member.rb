class Member < ActiveRecord::Base

  #for authlogin plugin
  # using email for the login id
  acts_as_authentic  do |c|
   c.login_field  'email'
  end
# looks like an old way to do defaults
#  attr_accessor_with_default :comment_type, 'biography'
#  attr_accessor_with_default :permalink, ''
# comment out for now
#  has_rakismet :author => :full_name,
#                 :author_email => :email,
#                 :author_url => :url,
#                 :content =>  :bio
#  
  belongs_to :occupation
  has_many :member_interests, :dependent => :destroy
  has_many :interests, :through => :member_interests

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
  
  def deliver_password_reset_instructions!  
    reset_perishable_token!   
    Notifier.deliver_password_reset_instructions(self)  
  end
end

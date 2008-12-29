class Member < ActiveRecord::Base
  belongs_to :occupation
  
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


end

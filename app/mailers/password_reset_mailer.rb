class PasswordResetMailer < ActionMailer::Base
  #xdefault_url_options[:host] = "members.austinonrails.org"  

  def message(member)  
  	debugger
    #@password_reset_url = edit_password_reset_url(member.perishable_token)
    mail(to: member.email, subject: "[austinonrails] Password Reset Instructions" )   
  end

end

class PasswordResetMailer < ActionMailer::Base
  default_url_options[:host] = "members.austinonrails.org"  
  default from:  "admin@austinonrails.com"
  def send_reset(member)
    @member = member
    @edit_password_reset_url = edit_password_reset_url(@member.perishable_token)
    mail(subject: "[austinonrails] Password Reset Instructions",
         to:  @member.email
    )
  end

end

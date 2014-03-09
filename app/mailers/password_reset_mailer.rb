class PasswordResetMailer < ActionMailer::Base
  default_url_options[:host] = "members.austinonrails.org"  

  def send_reset(member)
    @member = member
    @edit_password_reset_url = edit_password_reset_url(@member.perishable_token)
    mail(subject: "[austinonrails] Password Reset Instructions",
         from:    "admin@austinonrails.com",
         recipients:  @member.email,
         content_type: "text/html"
    )
  end

end

class Notifier < ActionMailer::Base
  default_url_options[:host] = "members.austinonrails.org"  

  def password_reset_instructions(member)  
    subject       "[austinonrails] Password Reset Instructions"  
    from          "Austin on Rails"  
    recipients    member.email  
    sent_on       Time.now  
    body          :edit_password_reset_url => edit_password_reset_url(member.perishable_token)  
  end

end

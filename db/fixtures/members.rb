require 'randexp'

50.times do
  member = Member.seed(:email) do |m|

    salt = Authlogic::CryptoProviders::Sha512.encrypt(Time.now.to_s + (1..10).collect{ rand.to_s }.join)
    
    m.first_name = Randgen.first_name
    m.last_name = Randgen.last_name
    m.email = "#{/\w{5,9}/.gen}@#{/\w{8,14}/.gen}.com"
    m.password = "password"
    m.password_confirmation = "password"
    m.crypted_password = Authlogic::CryptoProviders::Sha512.encrypt("password" + salt)
    m.password_salt = salt
    m.occupation_id = 1 + rand(2)
    m.url = "http://#{/\w{8,14}/.gen}.com"
    m.is_email_visible = rand(1)
    m.bio = /[:sentence:]/.gen
    m.twitter = /\w{5,15}/.gen
    m.github = /\w{5,15}/.gen
    m.created_at = rand(30).days.ago
    m.updated_at = rand(30).days.ago
  end
end
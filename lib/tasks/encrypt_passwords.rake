#ecrypts the pre-existing users' passwords using the authlogic method
#stored password_salt and crypted_password.  Deletes current password in clear text.
#It only operates on member records that have NIL for the current password_salt value.

desc "encrypt existing clear passwords"
task :encrypt_passwords => :environment do
  members = Member.find(:all)
  members.each do |m|
    if m.password_salt.nil?
      m.password_salt = Authlogic::CryptoProviders::Sha512.encrypt(Time.now.to_s + (1..10).collect{ rand.to_s }.join)
      m.crypted_password = Authlogic::CryptoProviders::Sha512.encrypt(m[:password] + m.password_salt)
      m[:password] = ''
      m.save(false)
    end
  end
end
namespace :dev do
  desc "Creates dummy members for development"
  task :data  => :environment do
    count = ENV['COUNT'] || 10
    (1..count).to_a.each do |number| 
      member = Member.create!(
        :first_name => Faker::Name.first_name,
        :last_name => Faker::Name.last_name,
        :email => Faker::Internet.email,
        :password => 'beo93QY!!',
        :password_confirmation => 'beo93QY!!',
        :url => Faker::Internet.url,
        :twitter => "@#{Faker::Internet.user_name}",
        :bio => Faker::Lorem.paragraphs(1),
        :github => "http://www.github.com/#{Faker::Internet.user_name}"
      )
    end

  end
end
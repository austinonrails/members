namespace :dev do
  desc "Creates COUNT=x dummy members for development"
  task :data  => :environment do
    count = ENV['COUNT'].to_i || 10
    (1..count).to_a.each do |number| 
      member = Member.create!(
        :first_name => Faker::Name.first_name,
        :last_name => Faker::Name.last_name,
        :email => Faker::Internet.email,
        :url => Faker::Internet.url,
        :password => '#foo123',
        :password_confirmation => '#foo123',
        :occupation_id => rand(3)+1,
        :bio => Faker::Lorem.paragraph(3), 
        :github => "#{Faker::Lorem.word}",
        :twitter => "#{Faker::Lorem.word}"

      )
    end

  end
end

FactoryGirl.define do
  factory :member do
    first_name "Bob"
    last_name "Jones"
    email "bob@example.com"
    password "123Bob#123"
    password_confirmation { password  }
  end
end
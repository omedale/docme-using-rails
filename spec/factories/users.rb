FactoryGirl.define do
  factory :user do
    name { Faker::Name.name  }
    email { Faker::Internet.unique.email }
    password_digest { Faker::Internet.password }
    role_id nil
  end
end
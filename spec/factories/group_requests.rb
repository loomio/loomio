# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :group_request do
    name Faker::Name.name
    expected_size 50
    description "MyText"
    admin_email Faker::Internet.email
    member_emails Faker::Internet.email
  end
end

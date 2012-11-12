# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :invitation do
    recipient_email "MyString"
    access_level "MyString"
    inviter_id 1
    group_id 1
  end
end

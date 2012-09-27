# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :invite do
    token "MyString"
    inviter nil
    recipient_email "MyString"
  end
end

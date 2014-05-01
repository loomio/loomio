# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email do
    to "MyString"
    from "MyString"
    reply_to "MyString"
    subject "MyString"
    body "MyText"
  end
end

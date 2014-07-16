# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contact do
    user nil
    name "MyString"
    email "MyString"
    source "MyString"
  end
end

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :announcement do
    message "MyText"
    starts_at "2013-04-22 14:39:07"
    ends_at "2013-04-22 14:39:07"
  end
end

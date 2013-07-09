# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :error_raincheck, :class => 'ErrorRainchecks' do
    email "MyString"
    action "MyString"
  end
end

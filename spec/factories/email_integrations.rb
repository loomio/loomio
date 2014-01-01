# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_integration do
    user
    association :email_integrable, :factory => :discussion
    token (('a'..'z').to_a +
               ('A'..'Z').to_a +
               (0..9).to_a).sample(20).join
  end
end

Given(/^a join instanty group exists$/) do
  @group = FactoryGirl.create :group, membership_granted_upon: 'request', discussion_privacy_options: 'public_only'
end


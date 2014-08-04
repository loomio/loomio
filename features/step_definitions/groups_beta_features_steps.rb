Given(/^there is a beta feature "(.*?)"$/) do |arg1|
end

When(/^I enable the beta feature "(.*?)"$/) do |arg1|
  @group = FactoryGirl.create(:group)
  @group.enabled_beta_features << 'discussion_iframe'
  @group.save
end

Then(/^the group should have "(.*?)" beta feature$/) do |arg1|
  @group.beta_feature_enabled?('discussion_iframe').should be true
end

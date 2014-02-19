When(/^I load the beta features settings page$/) do
  visit beta_features_path
end

When(/^enable the beta feature$/) do
  check 'does_nothing'
  click_on 'Update settings'
end

Then(/^the beta features should be enabled$/) do
  @user.reload
  @user.beta_feature_enabled?('does_nothing').should be_true
end

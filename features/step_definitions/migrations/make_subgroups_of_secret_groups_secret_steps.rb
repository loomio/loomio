Given(/^there is a public subgroup of a secret group$/) do
  @parent_group = FactoryGirl.create :group, privacy: 'secret'
  @sub_group = FactoryGirl.build :group, parent: @parent_group, privacy: 'public'
  @sub_group.save(validate: false)
end

When(/^I migrate public subgroups of secret groups$/) do
  require 'extras/migrations/20131129_migrate_subgroups_of_secret_groups_to_be_secret'
  MakeSubgroupsOfSecretGroupsSecret.now
end

Then(/^the public subgroup should be secret$/) do
  @sub_group.reload
  expect(@sub_group.privacy).to eq 'secret'
end

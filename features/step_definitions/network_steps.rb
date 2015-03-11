Given(/^I am ready to join network$/) do
  @user = FactoryGirl.create :user, name: 'user'
  @group = FactoryGirl.create :group, name: "Barcelona Circle"
  @group.add_admin! @user
  step 'I sign in'
  @network = Network.create(name: "Podemos")
end

When(/^I visit the request to join network page$/) do
  visit new_network_membership_request_path(@network)
end

When(/^fill in and submit the form$/) do
  select @group.full_name, from: :network_membership_request_group_id
  select @network.name, from: :network_membership_request_network_id
  fill_in :network_membership_request_message, with: "I want to join the Podemos network!"
  click_on 'Request to join Network'
end

Then(/^there should be a pending network membership request for my group$/) do
  NetworkMembershipRequest.all.count.should eq(1)
end

Given(/^there is a pending request to join the network$/) do
  @requestor = FactoryGirl.create :user, name: "Jim"
  @group = FactoryGirl.create :group, name: "Barcelona Circle"
  @group.add_admin! @requestor
  @user = FactoryGirl.create :user, name: "Sally"
  @network = Network.create(name: "Podemos", coordinators: [@user])
  step 'I sign in'
  NetworkMembershipRequest.create(requestor_id: @requestor.id, group_id: @group.id, network_id: @network.id, message: "Let me join the network please.")
end

When(/^I visit the network membership requests page$/) do
  visit network_membership_requests_path(@network)
end

When(/^I approve the pending request to join the network$/) do
  click_on "Approve"
end

When(/^I decline the pending request to join the network$/) do
  click_on "Decline"
end

Then(/^the group should be added to the network$/) do
  expect(@network.reload.groups.include? @group).to be true
end

Then(/^the group should not be added to the network$/) do
  expect(@network.reload.groups.include? @group).to be false
end
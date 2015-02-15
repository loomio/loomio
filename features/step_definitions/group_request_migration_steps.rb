Given(/^there is an approved GroupRequest$/) do
  @ben = FactoryGirl.create(:user, email: 'ben@loomio.org')
  @group = FactoryGirl.create(:group)
  @group_request = FactoryGirl.create(:group_request,
                                      name: "Friends of friends",
                                      description: "not what you would think",
                                      admin_email: "jim@dave.com",
                                      status: "approved",
                                      group_id: @group.id,
                                      expected_size: "25",
                                      max_size: 50,
                                      token: "iamatokennotanunforsoken")
end

When(/^I migrate Group Requests$/) do
  MigrateGroupRequests.now
end

Then(/^there should be an invitation to start that group$/) do
  @invitation = Invitation.find_by_token(@group_request.token)
  expect(@invitation.intent).to eq 'start_group'
  expect(@invitation.recipient_email).to eq @group_request.admin_email
  expect(@invitation.token).to eq @group_request.token
  expect(@invitation.invitable).to eq @group_request.group
end

When(/^I visit a GroupRequest\#start new group$/) do
  @ben = FactoryGirl.create(:user, email: 'ben@loomio.org')
  @group = FactoryGirl.create(:group)
  @group_request = FactoryGirl.create(:group_request,
                                      name: "Friends of friends",
                                      description: "not what you would think",
                                      admin_email: "jim@dave.com",
                                      status: "approved",
                                      group_id: @group.id,
                                      expected_size: "25",
                                      max_size: 50,
                                      token: "iamatokennotanunforsoken")
  MigrateGroupRequests.now
  @invitation = Invitation.find_by_token(@group_request.token)
  visit "/group_requests/328/start_new_group?token=#{@group_request.token}"
end

Then(/^I should be redirected to invitations with the same token$/) do
  expect(current_path).to eq invitation_path(@invitation)
end

require 'rails_helper'

describe GroupInviter do
  let(:group) { create :formal_group }
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:invitee) { create :user }

  before { group.add_admin! user }

  it 'invites users to a group'
  it 'creates users for emails and adds them to group'

  it 'respects invitation rate limiting' do
    ENV['MAX_PENDING_INVITATIONS'] = "1"

    expect {
      GroupInviter.new(group: group, inviter: user, emails: ['a@a.com']).invite!
    }.to_not raise_error { GroupInviter::NoInvitationsAvailableError }

    expect {
      GroupInviter.new(group: group, inviter: user, emails: ['b@b.com']).invite!
    }.to raise_error { GroupInviter::NoInvitationsAvailableError }

    expect {
      GroupInviter.new(group: group, inviter: user, user_ids: [invitee.id]).invite!
    }.to_not raise_error { GroupInviter::NoInvitationsAvailableError }

    group.add_admin! another_user
    expect {
      GroupInviter.new(group: group, inviter: another_user, emails: ['a@a.com']).invite!
    }.to_not raise_error { GroupInviter::NoInvitationsAvailableError }

    ENV['MAX_PENDING_INVITATIONS'] = nil
  end
end

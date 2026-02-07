require 'test_helper'

class Events::InvitationAcceptedTest < ActiveSupport::TestCase
  setup do
    @inviter = User.create!(name: "Inviter #{SecureRandom.hex(4)}", email: "inviter_#{SecureRandom.hex(4)}@test.com")
    @user = User.create!(name: "Invitee #{SecureRandom.hex(4)}", email: "invitee_#{SecureRandom.hex(4)}@test.com")
    @group = Group.create!(name: "Invite Group #{SecureRandom.hex(4)}", group_privacy: 'secret')
    @group.add_admin!(@inviter)
    membership = @user.memberships.new(group_id: @group.id)
    membership.inviter = @inviter
    membership.save!
    @membership = membership
  end

  test "creates an event" do
    assert_difference -> { Event.where(kind: 'invitation_accepted').count }, 1 do
      Events::InvitationAccepted.publish!(@membership)
    end
  end

  test "returns an event" do
    result = Events::InvitationAccepted.publish!(@membership)
    assert_kind_of Event, result
  end
end

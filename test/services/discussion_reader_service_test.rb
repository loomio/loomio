require 'test_helper'

class DiscussionReaderServiceTest < ActiveSupport::TestCase
  setup do
    @group = groups(:test_group)
    @discussion = create_discussion(group: @group, author: users(:normal_user))
    @user = users(:normal_user)
    @member = users(:another_user)
    @guest = User.create(email: "guest@example.com", email_verified: false, username: "guest123")

    @group.add_member!(@user)
    @group.add_member!(@member)

    @guest_discussion_reader = DiscussionReader.create(
      discussion: @discussion,
      user: @guest,
      guest: true,
      inviter: @discussion.author
    )
    @member_discussion_reader = DiscussionReader.create(
      discussion: @discussion,
      user: @member,
      inviter: @discussion.author
    )

    @discussion.created_event
  end

  test "redeems a guest discussion_reader" do
    assert_equal false, @guest.email_verified
    assert_equal true, @user.email_verified
    assert_equal @guest, @guest_discussion_reader.reload.user

    DiscussionReaderService.redeem(discussion_reader: @guest_discussion_reader, actor: @user)

    # After redeem, check that the user for this discussion has been changed
    redeemed_reader = DiscussionReader.find_by(discussion_id: @discussion.id, user_id: @user.id)
    assert_not_nil redeemed_reader
  end

  test "does not redeem reader for another verified user" do
    assert_equal @member, @member_discussion_reader.reload.user

    DiscussionReaderService.redeem(discussion_reader: @member_discussion_reader, actor: @user)

    assert_equal @member, @member_discussion_reader.reload.user
  end
end

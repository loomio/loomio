require 'test_helper'

class DiscussionReaderServiceTest < ActiveSupport::TestCase
  setup do
    @group = groups(:test_group)
    @user = users(:discussion_author)
    @member = users(:another_user)
    @discussion = discussions(:test_discussion)
    @guest = User.create(email: "guest@example.com", email_verified: false, username: "guest123")

    @guest_discussion_reader = TopicReader.create(
      topic: @discussion.topic,
      user: @guest,
      guest: true,
      inviter: @discussion.author
    )
    @member_discussion_reader = TopicReader.create(
      topic: @discussion.topic,
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
    redeemed_reader = TopicReader.find_by(topic: @discussion.topic, user_id: @user.id)
    assert_not_nil redeemed_reader
  end

  test "does not redeem reader for another verified user" do
    assert_equal @member, @member_discussion_reader.reload.user

    DiscussionReaderService.redeem(discussion_reader: @member_discussion_reader, actor: @user)

    assert_equal @member, @member_discussion_reader.reload.user
  end
end

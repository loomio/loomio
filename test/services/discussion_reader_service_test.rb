require 'test_helper'

class TopicReaderServiceTest < ActiveSupport::TestCase
  setup do
    @group = groups(:group)
    @admin = users(:admin)
    @member = users(:alien)
    @discussion = discussions(:discussion)
    @guest = User.create(email: "guest@example.com", email_verified: false, username: "guest123")

    @guest_reader = TopicReader.create(
      topic: @discussion.topic,
      user: @guest,
      guest: true,
      inviter: @discussion.author
    )
    @member_reader = TopicReader.create(
      topic: @discussion.topic,
      user: @member,
      inviter: @discussion.author
    )

    @discussion.created_event
  end

  test "redeems a guest topic_reader" do
    assert_equal false, @guest.email_verified
    assert_equal true, @admin.email_verified
    assert_equal @guest, @guest_reader.reload.user

    TopicReaderService.redeem(topic_reader: @guest_reader, actor: @admin)

    redeemed_reader = TopicReader.find_by(topic: @discussion.topic, user_id: @admin.id)
    assert_not_nil redeemed_reader
  end

  test "does not redeem reader for another verified user" do
    assert_equal @member, @member_reader.reload.user

    TopicReaderService.redeem(topic_reader: @member_reader, actor: @admin)

    assert_equal @member, @member_reader.reload.user
  end
end

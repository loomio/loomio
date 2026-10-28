require "test_helper"

class Ability::CommentTest < ActiveSupport::TestCase
  test "a member who can read another member's comment cannot discard it" do
    topic = topics(:discussion_topic)
    author = users(:user)
    reader = users(:member_normal)
    comment = CommentService.create(comment: Comment.new(parent: topic.topicable, body: 'Author-owned comment'), actor: author)

    assert reader.can?(:show, comment)
    assert author.can?(:discard, comment)
    assert users(:guest_admin_normal).can?(:discard, comment)
    assert_not reader.can?(:discard, comment)
  end

  test "a comment author loses discard permission when their topic guest access is revoked" do
    topic = topics(:discussion_topic)
    author = users(:guest_normal)
    comment = CommentService.create(comment: Comment.new(parent: topic.topicable, body: 'Guest-authored comment'), actor: author)
    assert author.can?(:discard, comment)

    topic.topic_readers.find_by!(user: author).update!(revoked_at: Time.current)
    author.reload

    assert_not author.can?(:show, comment)
    assert_not author.can?(:discard, comment)
  end
end

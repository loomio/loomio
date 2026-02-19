require 'test_helper'

class DiscussionEventIntegrationTest < ActiveSupport::TestCase
  setup do
    @commentor = User.create!(name: "Commentor #{SecureRandom.hex(4)}", email: "commentor_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    @viewer = User.create!(name: "Viewer #{SecureRandom.hex(4)}", email: "viewer_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    @group = Group.create!(name: "Integration Group #{SecureRandom.hex(4)}", group_privacy: 'secret')
    @group.add_admin!(@commentor)
    @group.add_member!(@viewer)

    @discussion = create_discussion(group: @group, author: @commentor)
    @first_comment = Comment.new(parent: @discussion, body: "First", author: @commentor)
    @second_comment = Comment.new(parent: @discussion, body: "Second", author: @commentor)
  end

  test "user has seen nothing, first comment deleted" do
    CommentService.create(comment: @first_comment, actor: @commentor)
    CommentService.create(comment: @second_comment, actor: @commentor)
    CommentService.destroy(comment: @first_comment, actor: @commentor)
    @discussion.reload
    dr = TopicReader.for(user: @viewer, topic: @discussion.topic)
    dr.save
    dr.reload
    assert_equal 1, @discussion.items_count - dr.read_items_count
  end

  test "user sees discussion before comments, first comment deleted" do
    dr = TopicReader.for(user: @viewer, topic: @discussion.topic)
    dr.save
    dr.viewed!

    CommentService.create(comment: @first_comment, actor: @commentor)
    CommentService.create(comment: @second_comment, actor: @commentor)
    CommentService.destroy(comment: @first_comment, actor: @commentor)
    @discussion.reload
    dr.reload
    assert_equal 1, @discussion.items_count - dr.read_items_count
  end
end

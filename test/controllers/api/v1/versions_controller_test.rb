require 'test_helper'

class Api::V1::VersionsControllerTest < ActionController::TestCase
  test "show returns version for comment" do
    user = users(:user)
    discussion = discussions(:discussion)
    comment = Comment.new(
      body: "Test comment",
      parent: discussion,
      author: user
    )
    CommentService.create(comment: comment, actor: user)

    sign_in user
    get :show, params: { comment_id: comment.id }
    assert_response :success
    version = response.parsed_body.fetch("versions").first
    assert_equal comment.id, version.fetch("item_id")
    assert_equal "Comment", version.fetch("item_type")
    assert_equal comment.versions.first.id, version.fetch("id")
  end

  test "show rejects an absent version without returning an empty success response" do
    comment = CommentService.create(comment: Comment.new(parent: topics(:discussion_topic).topicable, body: 'Versioned'), actor: users(:member_normal))
    sign_in users(:member_normal)

    get :show, params: { comment_id: comment.id, index: comment.versions.count }

    assert_response :not_found
  end

  test "show returns forbidden for discarded comment" do
    user = users(:user)
    discussion = discussions(:discussion)
    comment = Comment.new(
      body: "Test comment",
      parent: discussion,
      author: user
    )
    CommentService.create(comment: comment, actor: user)
    CommentService.discard(comment: comment, actor: user)

    sign_in user
    get :show, params: { comment_id: comment.id }
    assert_response :forbidden
  end
end

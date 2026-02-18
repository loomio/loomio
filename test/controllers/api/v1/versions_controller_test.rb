require 'test_helper'

class Api::V1::VersionsControllerTest < ActionController::TestCase
  test "show returns version for comment" do
    user = users(:normal_user)
    discussion = create_discussion(author: user, group: groups(:test_group))
    comment = Comment.new(
      body: "Test comment",
      discussion: discussion,
      author: user
    )
    CommentService.create(comment: comment, actor: user)
    
    sign_in user
    get :show, params: { comment_id: comment.id }
    assert_response :success
  end

  test "show returns forbidden for discarded comment" do
    user = users(:normal_user)
    discussion = create_discussion(author: user, group: groups(:test_group))
    comment = Comment.new(
      body: "Test comment",
      discussion: discussion,
      author: user
    )
    CommentService.create(comment: comment, actor: user)
    CommentService.discard(comment: comment, actor: user)
    
    sign_in user
    get :show, params: { comment_id: comment.id }
    assert_response :forbidden
  end
end

require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  setup do
    @comment = comments(:public_discussion_comment)
    @discussion = discussions(:public_discussion)
  end

  test "redirects to discussion path with comment_id" do
    get :redirect, params: { id: @comment.id }
    assert_redirected_to "/d/#{@discussion.key}?comment_id=#{@comment.id}"
  end

  test "returns 404 for missing comment" do
    get :redirect, params: { id: 0 }
    assert_response 404
  end
end

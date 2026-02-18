require 'test_helper'

class Api::V1::CommentsControllerTest < ActionController::TestCase
  setup do
    @user = users(:discussion_author)
    @another_user = users(:another_user)
    @group = groups(:test_group)
    @discussion = discussions(:test_discussion)

    @comment = Comment.new(discussion: @discussion, author: @user, body: "Original comment")
    CommentService.create(comment: @comment, actor: @user)

    @another_comment = Comment.new(discussion: @discussion, author: @another_user, body: "Another comment")
    CommentService.create(comment: @another_comment, actor: @another_user)
  end

  test "update success" do
    sign_in @user
    comment_params = { body: "updated content" }
    post :update, params: { id: @comment.id, comment: comment_params }
    assert_response :success
    assert_equal comment_params[:body], @comment.reload.body
  end

  test "update admins can edit user content true" do
    sign_in @user
    @group.add_admin!(@user)
    @group.update(admins_can_edit_user_content: true)
    comment_params = { body: "updated content" }
    post :update, params: { id: @another_comment.id, comment: comment_params }
    assert_response :success
    assert_equal comment_params[:body], @another_comment.reload.body
  end

  test "update admins can edit user content false" do
    sign_in @user
    @group.add_admin!(@user)
    @group.update(admins_can_edit_user_content: false)
    comment_params = { body: "updated content" }
    post :update, params: { id: @another_comment.id, comment: comment_params }
    assert_response :forbidden
  end

  test "update unpermitted params" do
    sign_in @user
    comment_params = { body: "updated content", dontmindme: "wild wooly byte virus" }
    put :update, params: { id: @comment.id, comment: comment_params }
    assert_response :bad_request
    json = JSON.parse(response.body)
    assert_includes json['exception'], 'ActionController::UnpermittedParameters'
  end

  test "update unauthorized user" do
    sign_in @another_user
    other_user = User.create!(name: "Other User", username: "otheruser", email: "other@example.com")
    sign_in other_user
    comment_params = { body: "updated content" }
    put :update, params: { id: @another_comment.id, comment: comment_params }
    assert_response :forbidden
    json = JSON.parse(response.body)
    assert_includes json['exception'], 'CanCan::AccessDenied'
  end

  test "update validation errors" do
    sign_in @user
    comment_params = { body: "" }
    put :update, params: { id: @comment.id, comment: comment_params }
    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_includes json['errors']['body'].join, "can't be blank"
  end

  test "create success" do
    sign_in @user
    comment_params = { discussion_id: @discussion.id, body: "original content" }
    assert_difference 'Comment.count', 1 do
      post :create, params: { comment: comment_params }
    end
    assert_response :success
  end

  test "create prevents xss src" do
    sign_in @user
    post :create, params: { comment: { discussion_id: @discussion.id, body: "<img src=\"javascript:alert('hi')\" >hello", body_format: "html" } }
    assert_response :success
    assert_equal "<img>hello", Comment.last.body
  end

  test "create prevents xss href" do
    sign_in @user
    post :create, params: { comment: { discussion_id: @discussion.id, body: "<a href=\"javascript:alert('hi')\" >hello</a>", body_format: "html" } }
    assert_response :success
  end

  test "create allows guests to comment" do
    sign_in @user
    @discussion.group.memberships.find_by(user: @user).destroy
    @discussion.add_guest!(@user, @discussion.author)

    comment_params = { discussion_id: @discussion.id, body: "original content" }
    assert_difference 'Comment.count', 1 do
      post :create, params: { comment: comment_params }
    end
    assert_response :success
  end

  test "create disallows aliens to comment" do
    sign_in @user
    @discussion.group.memberships.find_by(user: @user).destroy
    @discussion.discussion_readers.find_by(user: @user).destroy
    comment_params = { discussion_id: @discussion.id, body: "original content" }
    post :create, params: { comment: comment_params }
    assert_response :forbidden
  end

  test "create responds with discussion with reader" do
    sign_in @user
    comment_params = { discussion_id: @discussion.id, body: "original content" }
    post :create, params: { comment: comment_params }
    json = JSON.parse(response.body)
    assert json['discussions'][0]['discussion_reader_id'].present?
  end

  test "create responds with json" do
    sign_in @user
    comment_params = { discussion_id: @discussion.id, body: "original content" }
    post :create, params: { comment: comment_params }
    json = JSON.parse(response.body)
    assert_includes json.keys, "users"
    assert_includes json.keys, "comments"
  end

  test "create mentions appropriate users" do
    sign_in @user
    @group.add_member!(@another_user) unless @group.members.include?(@another_user)
    comment_params = { discussion_id: @discussion.id, body: "Hello, @#{@another_user.username}!" }
    assert_difference 'Event.where(kind: :user_mentioned).count', 1 do
      post :create, params: { comment: comment_params }, format: :json
    end
  end

  test "create does not invite non members to discussion" do
    sign_in @user
    non_member_user = User.create!(name: "Non Member", username: "nonmembercomment", email: "nonmembercomment@example.com")
    comment_params = { discussion_id: @discussion.id, body: "Hello, @#{non_member_user.username}!" }
    post :create, params: { comment: comment_params }, format: :json
    assert_response :success
  end

  test "create unpermitted params" do
    sign_in @user
    comment_params = { discussion_id: @discussion.id, body: "original content", dontmindme: "wild wooly byte virus" }
    post :create, params: { comment: comment_params }
    json = JSON.parse(response.body)
    assert_includes json['exception'], 'ActionController::UnpermittedParameters'
  end

  test "create validation errors" do
    sign_in @user
    comment_params = { discussion_id: @discussion.id, body: "" }
    post :create, params: { comment: comment_params }
    json = JSON.parse(response.body)
    assert_response :unprocessable_entity
    assert_includes json['errors']['body'].join, "can't be blank"
  end

  test "discard allowed" do
    sign_in @user
    delete :discard, params: { id: @comment.id }
    assert_response :success
    @comment.reload
    assert @comment.discarded?
    assert_equal @user.id, @comment.discarded_by
  end

  test "discard not allowed" do
    sign_in @another_user
    delete :discard, params: { id: @comment.id }
    assert_response :forbidden
    @comment.reload
    assert_not @comment.discarded?
  end
end

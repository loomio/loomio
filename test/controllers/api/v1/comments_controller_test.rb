require 'test_helper'

class Api::V1::CommentsControllerTest < ActionController::TestCase
  setup do
    @admin = users(:admin)
    @user = users(:user)
    @alien = users(:alien)
    @group = groups(:group)
    @discussion = discussions(:discussion)

    @admin_comment = Comment.new(parent: @discussion, author: @admin, body: "Admin comment")
    CommentService.create(comment: @admin_comment, actor: @admin)

    @user_comment = Comment.new(parent: @discussion, author: @user, body: "User comment")
    CommentService.create(comment: @user_comment, actor: @user)
  end

  test "update success" do
    sign_in @admin
    comment_params = { body: "updated content" }
    post :update, params: { id: @admin_comment.id, comment: comment_params }
    assert_response :success
    assert_equal comment_params[:body], @admin_comment.reload.body
  end

  test "update admins can edit user content true" do
    sign_in @admin
    @group.update(admins_can_edit_user_content: true)
    comment_params = { body: "updated content" }
    post :update, params: { id: @user_comment.id, comment: comment_params }
    assert_response :success
    assert_equal comment_params[:body], @user_comment.reload.body
  end

  test "update admins can edit user content false" do
    sign_in @admin
    @group.update(admins_can_edit_user_content: false)
    comment_params = { body: "updated content" }
    post :update, params: { id: @user_comment.id, comment: comment_params }
    assert_response :forbidden
  end

  test "update unpermitted params" do
    sign_in @user
    comment_params = { body: "updated content", dontmindme: "wild wooly byte virus" }
    put :update, params: { id: @user_comment.id, comment: comment_params }
    assert_response :bad_request
    json = JSON.parse(response.body)
    assert_includes json['exception'], 'ActionController::UnpermittedParameters'
  end

  test "update unauthorized user" do
    sign_in @alien
    other_user = User.create!(name: "Other User", username: "otheruser", email: "other@example.com")
    sign_in other_user
    comment_params = { body: "updated content" }
    put :update, params: { id: @user_comment.id, comment: comment_params }
    assert_response :forbidden
    json = JSON.parse(response.body)
    assert_includes json['exception'], 'CanCan::AccessDenied'
  end

  test "update validation errors" do
    sign_in @user
    comment_params = { body: "" }
    put :update, params: { id: @user_comment.id, comment: comment_params }
    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_includes json['errors']['body'].join, "can't be blank"
  end

  test "create success" do
    sign_in @user
    comment_params = { parent_type: 'Discussion', parent_id: @discussion.id, body: "original content" }
    assert_difference 'Comment.count', 1 do
      post :create, params: { comment: comment_params }
    end
    assert_response :success
  end

  test "create prevents xss src" do
    sign_in @user
    post :create, params: { comment: { parent_type: 'Discussion', parent_id: @discussion.id, body: "<img src=\"javascript:alert('hi')\" >hello", body_format: "html" } }
    assert_response :success
    assert_equal "<img>hello", Comment.last.body
  end

  test "create prevents xss href" do
    sign_in @user
    post :create, params: { comment: { parent_type: 'Discussion', parent_id: @discussion.id, body: "<a href=\"javascript:alert('hi')\" >hello</a>", body_format: "html" } }
    assert_response :success
  end

  test "create allows guests to comment" do
    sign_in @user
    @discussion.group.memberships.find_by(user: @user).destroy
    @discussion.add_guest!(@user, @discussion.author)

    comment_params = { parent_type: 'Discussion', parent_id: @discussion.id, body: "original content" }
    assert_difference 'Comment.count', 1 do
      post :create, params: { comment: comment_params }
    end
    assert_response :success
  end

  test "create disallows aliens to comment" do
    sign_in @user
    @discussion.group.memberships.find_by(user: @user).destroy
    @discussion.topic_readers.find_by(user: @user).destroy
    comment_params = { parent_type: 'Discussion', parent_id: @discussion.id, body: "original content" }
    post :create, params: { comment: comment_params }
    assert_response :forbidden
  end

  test "create responds with discussion and topic with reader" do
    sign_in @user
    comment_params = { parent_type: 'Discussion', parent_id: @discussion.id, body: "original content" }
    post :create, params: { comment: comment_params }
    json = JSON.parse(response.body)
    assert json['discussions'][0].present?
    assert json['topics'][0]['topic_reader_id'].present?
  end

  test "create responds with json" do
    sign_in @user
    comment_params = { parent_type: 'Discussion', parent_id: @discussion.id, body: "original content" }
    post :create, params: { comment: comment_params }
    json = JSON.parse(response.body)
    assert_includes json.keys, "users"
    assert_includes json.keys, "comments"
  end

  test "create mentions appropriate users" do
    sign_in @user
    @group.add_member!(@alien) unless @group.members.include?(@alien)
    comment_params = { parent_type: 'Discussion', parent_id: @discussion.id, body: "Hello, @#{@alien.username}!" }
    assert_difference 'Event.where(kind: :user_mentioned).count', 1 do
      post :create, params: { comment: comment_params }, format: :json
    end
  end

  test "create does not invite non members to discussion" do
    sign_in @user
    non_member_user = User.create!(name: "Non Member", username: "nonmembercomment", email: "nonmembercomment@example.com")
    comment_params = { parent_type: 'Discussion', parent_id: @discussion.id, body: "Hello, @#{non_member_user.username}!" }
    post :create, params: { comment: comment_params }, format: :json
    assert_response :success
  end

  test "create unpermitted params" do
    sign_in @user
    comment_params = { parent_type: 'Discussion', parent_id: @discussion.id, body: "original content", dontmindme: "wild wooly byte virus" }
    post :create, params: { comment: comment_params }
    json = JSON.parse(response.body)
    assert_includes json['exception'], 'ActionController::UnpermittedParameters'
  end

  test "create validation errors" do
    sign_in @user
    comment_params = { parent_type: 'Discussion', parent_id: @discussion.id, body: "" }
    post :create, params: { comment: comment_params }
    json = JSON.parse(response.body)
    assert_response :unprocessable_entity
    assert_includes json['errors']['body'].join, "can't be blank"
  end

  test "discard allowed" do
    sign_in @admin
    delete :discard, params: { id: @admin_comment.id }
    assert_response :success
    @admin_comment.reload
    assert @admin_comment.discarded?
    assert_equal @admin.id, @admin_comment.discarded_by
  end

  test "discard not allowed" do
    sign_in @alien
    delete :discard, params: { id: @admin_comment.id }
    assert_response :forbidden
    @admin_comment.reload
    assert_not @admin_comment.discarded?
  end
end

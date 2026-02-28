require 'test_helper'

class Api::HocuspocusControllerTest < ActionController::TestCase
  setup do
    @user = users(:admin)
    @group = groups(:group)
    @discussion = discussions(:discussion)
    hex = SecureRandom.hex(4)
    @other_user = User.create!(name: "other#{hex}", email: "other#{hex}@example.com", username: "other#{hex}", email_verified: true)
    @other_group = Group.create!(name: "hpother#{hex}", handle: "hpother#{hex}", group_privacy: 'secret')
    @other_group.add_admin!(@other_user)
    @other_discussion = DiscussionService.create(params: { title: "Other #{SecureRandom.hex(4)}", group_id: @other_group.id }, actor: @other_user)
    ActionMailer::Base.deliveries.clear
  end

  # Logged out user tests
  test "logged out allows new groups" do
    post :create, params: {
      user_secret: "0,anything at all",
      document_name: "group-new-#{@user.id}-1-1-1"
    }
    assert_response 200
  end

  test "logged out denies non groups" do
    post :create, params: {
      user_secret: "0,anything at all",
      document_name: "discussion-new-#{@user.id}-1-1-1"
    }
    assert_response 401
  end

  # New comment tests
  test "new comment valid secret_token returns 200" do
    post :create, params: {
      user_secret: "#{@user.id},#{@user.secret_token}",
      document_name: "comment-new-#{@user.id}-1-1-1"
    }
    assert_response 200
  end

  test "new comment invalid secret_token returns 401" do
    post :create, params: {
      user_secret: "#{@user.id},1203987120983120",
      document_name: "comment-new-#{@user.id}-1-1-1"
    }
    assert_response 401
  end

  test "new comment wrong user_id returns 401" do
    post :create, params: {
      user_secret: "#{@user.id}1,#{@user.secret_token}",
      document_name: "comment-new-#{@user.id}-1-1-1"
    }
    assert_response 401
  end

  test "new comment wrong user_id in document returns 401" do
    post :create, params: {
      user_secret: "#{@user.id},#{@user.secret_token}",
      document_name: "comment-new-#{@user.id}1-1-1-1"
    }
    assert_response 401
  end

  # Existing discussion tests
  test "existing discussion valid secret_token returns 200" do
    post :create, params: {
      user_secret: "#{@user.id},#{@user.secret_token}",
      document_name: "discussion-#{@discussion.id}-description"
    }
    assert_response 200
  end

  test "existing discussion invalid secret_token returns 401" do
    post :create, params: {
      user_secret: "#{@user.id},#{@user.secret_token}12",
      document_name: "discussion-#{@discussion.id}-description"
    }
    assert_response 401
  end

  test "existing discussion other discussion returns 401" do
    post :create, params: {
      user_secret: "#{@user.id},#{@user.secret_token}",
      document_name: "discussion-#{@other_discussion.id}-description"
    }
    assert_response 401
  end
end

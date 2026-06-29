require 'test_helper'

class Api::V1::NotificationsControllerTest < ActionController::TestCase
  setup do
    @user  = users(:user)
    @admin = users(:admin)
  end

  test "index returns notifications for accessible topics" do
    notification = Notification.create!(user: @user, actor: @admin, event: events(:discussion_created_event), viewed: false)
    sign_in @user
    get :index
    assert_response :success
    ids = JSON.parse(response.body)['notifications'].map { |n| n['id'] }
    assert_includes ids, notification.id
  end

  test "index excludes notifications whose topic is not accessible" do
    notification = Notification.create!(user: @user, actor: users(:alien), event: events(:alien_discussion_created_event), viewed: false)
    sign_in @user
    get :index
    assert_response :success
    ids = JSON.parse(response.body)['notifications'].map { |n| n['id'] }
    assert_not_includes ids, notification.id
  end

  test "index excludes notifications for discarded comments" do
    comment = comments(:public_discussion_comment)
    notification = Notification.create!(user: @user, actor: @admin, event: events(:public_discussion_comment_event), viewed: false)
    comment.update!(discarded_at: Time.current)
    sign_in @user
    get :index
    assert_response :success
    ids = JSON.parse(response.body)['notifications'].map { |n| n['id'] }
    assert_not_includes ids, notification.id
  end
end

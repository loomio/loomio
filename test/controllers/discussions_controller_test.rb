require 'test_helper'

class DiscussionsControllerTest < ActionController::TestCase
  setup do
    hex = SecureRandom.hex(4)
    @user = User.create!(name: "user#{hex}", email: "user#{hex}@example.com", username: "user#{hex}", email_verified: true)
    @group = Group.new(name: "discgroup#{hex}", group_privacy: 'closed', is_visible_to_public: true)
    @group.creator = @user
    @group.save!
    @group.add_member!(@user)
    @discussion = Discussion.new(title: "Test Discussion #{hex}", group: @group, author: @user, private: true)
    DiscussionService.create(discussion: @discussion, actor: @user)
    ActionMailer::Base.deliveries.clear
  end

  test "show 200 ssr and boot for signed in member" do
    sign_in @user
    get :show, params: { key: @discussion.key }
    assert_response 200
    assert_equal @discussion, assigns(:discussion)
  end

  test "show 404 for non-existent discussion" do
    get :show, params: { key: 'doesnotexist' }
    assert_response 404
    assert_nil assigns(:discussion)
  end

  test "signed in displays xml feed" do
    sign_in @user
    get :show, params: { key: @discussion.key }, format: :xml
    assert_response 200
    assert_equal @discussion, assigns(:discussion)
  end

  test "signed out displays xml feed for public discussion" do
    @discussion.update_columns(private: false)
    get :show, params: { key: @discussion.key }, format: :xml
    assert_response 200
    assert_equal @discussion, assigns(:discussion)
  end
end

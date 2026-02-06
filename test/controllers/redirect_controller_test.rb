require 'test_helper'

class RedirectControllerTest < ActionController::TestCase
  setup do
    @user = users(:normal_user)
    @group = groups(:test_group)
    @group.add_admin!(@user)
    @discussion = create_discussion(group: @group, author: @user)
  end

  test "redirects to group path" do
    get :group, params: { id: @group.key }
    assert_redirected_to "/g/#{@group.key}"
  end

  test "redirects to discussion path" do
    get :discussion, params: { id: @discussion.key }
    assert_redirected_to discussion_path(@discussion)
  end
end

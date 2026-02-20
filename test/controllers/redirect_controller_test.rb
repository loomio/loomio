require 'test_helper'

class RedirectControllerTest < ActionController::TestCase
  setup do
    @group = groups(:test_group)
    @discussion = discussions(:test_discussion)
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

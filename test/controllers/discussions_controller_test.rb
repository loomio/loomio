require 'test_helper'

class DiscussionsControllerTest < ActionController::TestCase
  setup do
    @user = users(:user)
    @group = groups(:group)
    @discussion = discussions(:discussion)
  end

  test "show 200 ssr and boot for signed in member" do
    sign_in @user
    get :show, params: { key: @discussion.key }
    assert_response 200
    assert_equal @discussion, assigns(:discussion)
  end

  test "public discussion has a clean canonical URL" do
    discussion = discussions(:public_discussion)
    get :show, params: { key: discussion.key, offset: 0, limit: 1, export: 1, sign_in: 1 }

    assert_response 200
    assert_select "link[rel='canonical'][href=?]", discussion_url(discussion)
    assert_select "meta[property='og:url'][content=?]", discussion_url(discussion)
    assert_select "meta[name='robots'][content='noindex,follow']"
    assert_select "a.navbar__sign-in[href='/dashboard']"
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
    discussion = discussions(:public_discussion)
    get :show, params: { key: discussion.key }, format: :xml
    assert_response 200
    assert_equal discussion, assigns(:discussion)
  end

  test "xml feed renders comment links using contextual topic route" do
    # Regression: comment_url was called with wrong params (key:, comment_id:)
    # causing ActionController::UrlGenerationError (missing required key :id)
    discussion = discussions(:public_discussion)
    get :show, params: { key: discussion.key }, format: :xml
    assert_response 200
    assert_match %r{/d/#{discussion.key}\?comment_id=\d+}, @response.body
  end
end

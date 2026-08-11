require "test_helper"

class ApiAccessControllerTest < ActionController::TestCase
  setup do
    @user = users(:user)
    @alien = users(:alien)
    @group = groups(:group)
    @subgroup = groups(:subgroup)
    @alien_group = groups(:alien_group)
  end

  test "signed out users cannot read API access details" do
    get :show

    assert_redirected_to dashboard_path
    refute_includes response.body, @user.api_key
  end

  test "signed in user sees their API key and group IDs" do
    sign_in @user

    get :show

    assert_response :success
    assert_select "h1", "API access"
    assert_select "code.api-access__key", @user.api_key
    assert_select "a[href='/g/#{@group.key}']", @group.name
    assert_select "a[href='/g/#{@subgroup.key}']", @subgroup.name
    assert_select "td code", text: @group.id.to_s
    assert_select "td code", text: @subgroup.id.to_s
  end

  test "signed in user cannot see another user's API key or groups" do
    sign_in @user

    get :show

    assert_response :success
    refute_includes response.body, @alien.api_key
    refute_includes response.body, @alien_group.name
    assert_select "a[href='/g/#{@alien_group.key}']", count: 0
  end

  test "signed in user cannot see groups from unaccepted invitations" do
    pending_group = groups(:public_group)
    Membership.create!(
      user: @user,
      group: pending_group,
      inviter: @alien,
      accepted_at: nil
    )
    sign_in @user

    get :show

    assert_response :success
    refute_includes response.body, pending_group.name
    assert_select "a[href='/g/#{pending_group.key}']", count: 0
  end

  test "signed in user can open the page with a dangling membership" do
    dangling_membership = Membership.create!(
      user: @user,
      group: groups(:public_group),
      inviter: @alien,
      accepted_at: Time.current
    )
    dangling_membership.update_columns(group_id: -1)
    sign_in @user

    get :show

    assert_response :success
    assert_select "code.api-access__key", @user.api_key
    assert_select "a[href='/g/#{@group.key}']", @group.name
    assert_select "a[href='/g/#{@subgroup.key}']", @subgroup.name
  end

  test "API access page is not cached and does not load JavaScript" do
    sign_in @user

    get :show

    assert_response :success
    assert_includes response.headers["Cache-Control"], "no-store"
    assert_equal "no-referrer", response.headers["Referrer-Policy"]
    assert_select "meta[name=robots][content='noindex,nofollow']"
    assert_select "meta[name=referrer][content='no-referrer']"
    assert_select "script", count: 0
    refute_includes response.body, "client3"
  end

  test "API access page links to the API help pages" do
    sign_in @user

    get :show

    assert_response :success
    assert_select "a[href='/docs/en/user_manual/integrations/api/user-api']"
    assert_select "a[href='/docs/en/user_manual/integrations/api']"
    assert_select "a[href='/docs/en/user_manual/integrations/api/server-api']"
  end

  test "API access route uses the server-rendered controller" do
    assert_routing(
      { method: "get", path: "/profile/api_access" },
      { controller: "api_access", action: "show" }
    )
  end
end

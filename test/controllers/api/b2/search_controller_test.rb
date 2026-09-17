require "test_helper"

class Api::B2::SearchControllerTest < ActionController::TestCase
  setup do
    hex = SecureRandom.hex(4)
    @user = User.create!(
      name: "searcher#{hex}",
      email: "searcher#{hex}@example.com",
      username: "searcher#{hex}",
      email_verified: true
    )
    @user.update_columns(api_key: "searchkey#{SecureRandom.hex(8)}")
    @public_discussion = discussions(:public_discussion)
    @private_discussion = discussions(:discussion)
    @public_discussion.update!(title: "b2searchterm public")
    @private_discussion.update!(title: "b2searchterm private")
    @public_discussion.update_pg_search_document
    @private_discussion.update_pg_search_document
    @request.headers["Authorization"] = "Bearer #{@user.api_key}"
  end

  test "searches public content without group membership and excludes private content" do
    get :index, params: { query: "b2searchterm" }

    assert_response :success
    results = response.parsed_body.fetch("search_results")
    assert results.any? { |result| result["searchable_type"] == "Discussion" && result["searchable_id"] == @public_discussion.id }
    refute results.any? { |result| result["searchable_id"] == @private_discussion.id }
  end

  test "searches private content available through membership" do
    groups(:group).add_member!(@user)

    get :index, params: { query: "b2searchterm", group_id: groups(:group).id }

    assert_response :success
    results = response.parsed_body.fetch("search_results")
    assert results.any? { |result| result["searchable_id"] == @private_discussion.id }
  end

  test "instance admin status does not expose private search results" do
    @user.update!(is_admin: true)

    get :index, params: { query: "b2searchterm" }

    assert_response :success
    results = response.parsed_body.fetch("search_results")
    refute results.any? { |result| result["searchable_id"] == @private_discussion.id }
  end

  test "requires a bearer API key" do
    @request.headers["Authorization"] = nil

    get :index, params: { api_key: @user.api_key, query: "b2searchterm" }

    assert_response :forbidden
  end

  test "omits an undefined total rather than returning null" do
    get :index, params: { query: "b2searchterm" }

    assert_response :success
    refute response.parsed_body.fetch("meta").key?("total")
  end
end

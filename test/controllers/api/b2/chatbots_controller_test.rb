require "test_helper"

class Api::B2::ChatbotsControllerTest < ActionController::TestCase
  setup do
    @admin = users(:admin)
    @member = users(:member)
    @group = groups(:group)
    @alien_group = groups(:alien_group)
    @admin.update_columns(api_key: "admin-api-key-#{SecureRandom.hex(8)}")
    @member.update_columns(api_key: "member-api-key-#{SecureRandom.hex(8)}")
    @request.headers["Authorization"] = "Bearer #{@admin.api_key}"

    SafeHttpService.stub(:safe_to_fetch?, true) do
      @chatbot = Chatbot.create!(
        name: "API webhook",
        group: @group,
        author: @admin,
        kind: "webhook",
        webhook_kind: "markdown",
        server: "https://hooks.example.test/loomio",
        event_kinds: [ "new_discussion" ]
      )
    end
  end

  test "group admin can list webhook configurations including their destination" do
    get :index, params: { group_id: @group.id }

    assert_response :success
    webhook = json.fetch("chatbots").find { |record| record["id"] == @chatbot.id }
    assert_equal @chatbot.server, webhook.fetch("server")
    assert_equal [ "new_discussion" ], webhook.fetch("event_kinds")
  end

  test "pages only the selected group's webhooks and preserves the full total" do
    SafeHttpService.stub(:safe_to_fetch?, true) do
      @group.chatbots.create!(
        name: "Second API webhook", author: @admin, kind: "webhook",
        server: "https://hooks.example.test/second"
      )
    end
    expected_ids = @group.chatbots.order(:id).pluck(:id)
    actual_ids = expected_ids.each_index.flat_map do |offset|
      get :index, params: { group_id: @group.id, limit: 1, offset: offset }

      assert_response :success
      assert_equal expected_ids.length, json.dig("meta", "total")
      assert_equal 1, json.fetch("chatbots").length
      assert_equal @group.id, json.fetch("chatbots").first.fetch("group_id")
      assert json.fetch("chatbots").first.fetch("server").present?
      json.fetch("chatbots").pluck("id")
    end
    assert_equal expected_ids, actual_ids

    get :index, params: { group_id: @group.id, limit: 1, offset: expected_ids.length }

    assert_response :success
    assert_empty json.fetch("chatbots")
    assert_equal expected_ids.length, json.dig("meta", "total")
  end

  test "pagination does not reveal webhook destinations or totals to unauthorized roles" do
    %i[member guest_admin_normal former_member_loud alien server_admin inactive_member_loud].each do |role|
      user = users(role)
      user.update_columns(api_key: "webhook-page-key-#{SecureRandom.hex(8)}")
      @request.headers["Authorization"] = "Bearer #{user.api_key}"

      get :index, params: { group_id: @group.id, limit: 1, offset: 1 }

      assert_response(role == :inactive_member_loud ? :forbidden : :not_found)
      refute json.key?("chatbots"), role.to_s
      refute json.key?("meta"), role.to_s
      refute_includes response.body, @chatbot.server
    end
  end

  test "group admin can create update and destroy a webhook" do
    SafeHttpService.stub(:safe_to_fetch?, true) do
      post :create, params: {
        group_id: @group.id,
        name: "Created through API",
        kind: "webhook",
        webhook_kind: "markdown",
        server: "https://hooks.example.test/created",
        event_kinds: [ "new_comment", "poll_created" ]
      }
    end

    assert_response :success
    chatbot = Chatbot.find(json.fetch("chatbots").first.fetch("id"))
    assert_equal @admin, chatbot.author
    assert_equal "https://hooks.example.test/created", json.fetch("chatbots").first.fetch("server")

    SafeHttpService.stub(:safe_to_fetch?, true) do
      patch :update, params: {
        id: chatbot.id,
        group_id: @alien_group.id,
        name: "Updated through API",
        server: "https://hooks.example.test/updated"
      }
    end

    assert_response :success
    assert_equal "Updated through API", chatbot.reload.name
    assert_equal @group, chatbot.group
    assert_equal "https://hooks.example.test/updated", json.fetch("chatbots").first.fetch("server")
    assert_equal "Updated through API", json.fetch("chatbots").first.fetch("name")

    delete :destroy, params: { id: chatbot.id }

    assert_response :success
    refute Chatbot.exists?(chatbot.id)
    assert_equal({ "success" => "success" }, json)
  end

  test "group admin can test a webhook destination" do
    published_params = nil

    ChatbotService.stub(:publish_test!, ->(**params) { published_params = params }) do
      post :check, params: { group_id: @group.id, server: "https://hooks.example.test/check" }
    end

    assert_response :success
    assert_equal({ server: "https://hooks.example.test/check", kind: "slack_webhook" }, published_params)
  end

  test "webhook checks reject non-coordinators before sending to the supplied destination" do
    ChatbotService.stub(:publish_test!, ->(**) { flunk 'unauthorized webhook must not be sent' }) do
      %i[member_normal guest_admin_normal former_member_loud alien server_admin].each do |role|
        actor = users(role)
        actor.update_columns(api_key: "webhook-check-#{SecureRandom.hex(8)}")
        @request.headers['Authorization'] = "Bearer #{actor.api_key}"
        post :check, params: { group_id: @group.id, server: 'https://hooks.example.test/check' }
        assert_response :not_found
      end
    end
  end

  test "ordinary group member cannot manage webhooks" do
    @request.headers["Authorization"] = "Bearer #{@member.api_key}"

    get :index, params: { group_id: @group.id }
    assert_response :not_found

    patch :update, params: { id: @chatbot.id, name: "Unauthorized" }
    assert_response :not_found
    assert_equal "API webhook", @chatbot.reload.name
  end

  test "group admin cannot manage another group's webhooks" do
    other_webhook = nil
    SafeHttpService.stub(:safe_to_fetch?, true) do
      other_webhook = Chatbot.create!(
        name: "Other webhook",
        group: @alien_group,
        author: users(:alien),
        kind: "webhook",
        webhook_kind: "markdown",
        server: "https://hooks.example.test/other"
      )
    end

    patch :update, params: { id: other_webhook.id, name: "Unauthorized" }

    assert_response :not_found
    assert_equal "Other webhook", other_webhook.reload.name
  end

  test "requires a valid bearer API key" do
    @request.headers["Authorization"] = "Bearer invalid"

    get :index, params: { group_id: @group.id }

    assert_response :forbidden
  end

  private

  def json
    JSON.parse(response.body)
  end
end

require 'test_helper'

class Api::V1::ChatbotsControllerTest < ActionController::TestCase
  setup do
    @admin = users(:admin)
    @member = users(:member)
    @group = groups(:group)
    @alien_group = groups(:alien_group)
    SafeHttpService.stub(:safe_to_fetch?, true) do
      @chatbot = Chatbot.create!(
        name: 'Test webhook',
        group: @group,
        author: @admin,
        kind: 'webhook',
        webhook_kind: 'slack',
        server: 'https://hooks.example.test/'
      )
    end
  end

  test "index reveals webhook configuration only to coordinators and stays within the selected group" do
    @chatbot.update_column(:channel, 'coordinator-channel')
    SafeHttpService.stub(:safe_to_fetch?, true) do
      Chatbot.create!(name: 'Other group webhook', group: @alien_group, author: users(:alien),
                      kind: 'webhook', webhook_kind: 'slack', server: 'https://other-hooks.example.test/')
    end

    [[@admin, true], [@member, false]].each do |actor, coordinator|
      sign_in actor
      get :index, params: { group_id: @group.id }

      assert_response :success
      chatbots = response.parsed_body.fetch('chatbots')
      assert_equal [@chatbot.id], chatbots.pluck('id')
      chatbot = chatbots.first
      if coordinator
        assert_equal @chatbot.server, chatbot.fetch('server')
        assert_equal 'coordinator-channel', chatbot.fetch('channel')
      else
        refute chatbot.key?('server')
        refute chatbot.key?('channel')
      end
    end
  end

  test "index denies topic guests revoked members outsiders and instance administrators" do
    %i[guest_normal former_member_loud alien server_admin].each do |role|
      sign_in users(role)
      get :index, params: { group_id: @group.id }

      assert_response :forbidden, role.to_s
      refute response.parsed_body.key?('chatbots'), role.to_s
    end
  end

  test "update ignores group_id transfer" do
    sign_in @admin

    SafeHttpService.stub(:safe_to_fetch?, true) do
      patch :update, params: {
        id: @chatbot.id,
        chatbot: {
          name: 'Updated webhook',
          group_id: @alien_group.id,
          kind: 'webhook',
          webhook_kind: 'slack',
          server: 'https://hooks.example.test/'
        }
      }
    end

    assert_response :success
    assert_equal @group.id, @chatbot.reload.group_id
    assert_equal 'Updated webhook', @chatbot.name
  end

  test "check requires a group admin" do
    sign_in @member

    post :check, params: {
      group_id: @group.id,
      kind: 'slack_webhook',
      server: 'https://hooks.example.test/'
    }

    assert_response :not_found
  end

  test "check requires a signed in user" do
    post :check, params: {
      group_id: @group.id,
      kind: 'slack_webhook',
      server: 'https://hooks.example.test/'
    }

    assert_response :unauthorized
  end

  test "check rejects unsafe server urls" do
    sign_in @admin

    SafeHttpService.stub(:safe_to_fetch?, false) do
      post :check, params: {
        group_id: @group.id,
        kind: 'slack_webhook',
        server: 'http://127.0.0.1:3000/'
      }
    end

    assert_response :forbidden
  end

  test "check cannot publish for a disabled group even for its coordinator" do
    @group.add_admin!(@member)
    sign_in @member
    assert @member.can?(:update, @group)
    @group.update!(subscription: subscriptions(:cleanup_canceled_free))

    ChatbotService.stub(:publish_test!, ->(*) { flunk 'disabled groups must not publish webhook tests' }) do
      post :check, params: { group_id: @group.id, kind: 'slack_webhook', server: 'https://hooks.example.test/' }
    end

    assert_response :forbidden
  end

  test "check posts to safe webhook urls" do
    sign_in @admin

    WebMock.stub_request(:post, 'https://hooks.example.test/').to_return(status: 200)

    Resolv.stub(:getaddresses, ['93.184.216.34']) do
      post :check, params: {
        group_id: @group.id,
        kind: 'slack_webhook',
        server: 'https://hooks.example.test/'
      }
    end

    assert_response :ok
    assert_requested :post, 'https://hooks.example.test/'
  end
end

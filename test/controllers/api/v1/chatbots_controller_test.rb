require 'test_helper'

class Api::V1::ChatbotsControllerTest < ActionController::TestCase
  setup do
    @admin = users(:admin)
    @member = users(:member)
    @group = groups(:group)
    @alien_group = groups(:alien_group)
    LinkPreviewService.stub(:safe_to_fetch?, true) do
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

  test "update ignores group_id transfer" do
    sign_in @admin

    LinkPreviewService.stub(:safe_to_fetch?, true) do
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

    LinkPreviewService.stub(:safe_to_fetch?, false) do
      post :check, params: {
        group_id: @group.id,
        kind: 'slack_webhook',
        server: 'http://127.0.0.1:3000/'
      }
    end

    assert_response :forbidden
  end

  test "check posts to safe webhook urls" do
    sign_in @admin

    WebMock.stub_request(:post, 'https://hooks.example.test/').to_return(status: 200)

    LinkPreviewService.stub(:safe_to_fetch?, true) do
      post :check, params: {
        group_id: @group.id,
        kind: 'slack_webhook',
        server: 'https://hooks.example.test/'
      }
    end

    assert_response :success
  end
end

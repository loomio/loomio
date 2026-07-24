require 'test_helper'

class ChatbotServiceTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @group = groups(:group)
    @event = events(:discussion_created_event)
  end

  test "publish_event posts to chatbots subscribed to the event kind" do
    matching_url = 'https://hooks.example.test/matching'
    non_matching_url = 'https://hooks.example.test/non-matching'

    LinkPreviewService.stub(:safe_to_fetch?, true) do
      Chatbot.create!(
        name: 'Matching webhook',
        group: @group,
        author: @admin,
        kind: 'webhook',
        webhook_kind: 'slack',
        server: matching_url,
        event_kinds: [@event.kind]
      )
      Chatbot.create!(
        name: 'Non-matching webhook',
        group: @group,
        author: @admin,
        kind: 'webhook',
        webhook_kind: 'slack',
        server: non_matching_url,
        event_kinds: ['poll_created']
      )
    end

    WebMock.stub_request(:post, matching_url).to_return(status: 200)
    WebMock.stub_request(:post, non_matching_url).to_return(status: 200)

    # Delivery now resolves + IP-pins the host (SSRF guard), so stub DNS.
    Resolv.stub(:getaddresses, ->(host) { host == 'hooks.example.test' ? ['93.184.216.34'] : [] }) do
      ChatbotService.publish_event!(@event.id)
    end

    assert_requested :post, matching_url, times: 1
    assert_not_requested :post, non_matching_url
  end

  test "publish_event does not deliver to a webhook host that resolves to a blocked internal IP (SSRF guard)" do
    internal_url = 'https://rebind.example.test/hook'

    LinkPreviewService.stub(:safe_to_fetch?, true) do
      Chatbot.create!(
        name: 'Rebinding webhook',
        group: @group,
        author: @admin,
        kind: 'webhook',
        webhook_kind: 'slack',
        server: internal_url,
        event_kinds: [@event.kind]
      )
    end

    WebMock.stub_request(:post, internal_url).to_return(status: 200)

    # Host now resolves to the cloud-metadata address — delivery must be dropped.
    Resolv.stub(:getaddresses, ->(_host) { ['169.254.169.254'] }) do
      ChatbotService.publish_event!(@event.id)
    end

    assert_not_requested :post, internal_url
  end
end

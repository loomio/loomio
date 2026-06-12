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

    ChatbotService.publish_event!(@event.id)

    assert_requested :post, matching_url, times: 1
    assert_not_requested :post, non_matching_url
  end
end

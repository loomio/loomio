require 'test_helper'

class NewsletterServiceTest < ActiveSupport::TestCase
  setup do
    @connection = Faraday.new(url: 'https://listmonk.test') do |faraday|
      faraday.request :authorization, :basic, 'username', 'password'
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end
  end

  test "subscribes with basic authentication and a JSON body" do
    WebMock.stub_request(:post, 'https://listmonk.test/api/subscribers').
      with(
        basic_auth: %w[username password],
        headers: { 'Content-Type' => 'application/json' },
        body: hash_including(
          email: 'pat@example.test',
          name: 'Pat Example',
          status: 'enabled',
          preconfirm_subscriptions: true
        )
      ).
      to_return(status: 200, body: '{}')

    NewsletterService.stub(:enabled?, true) do
      NewsletterService.stub(:connection, @connection) do
        NewsletterService.subscribe('Pat Example', 'pat@example.test')
      end
    end

    assert_requested :post, 'https://listmonk.test/api/subscribers'
  end

  test "looks up and deletes a subscriber" do
    WebMock.stub_request(:get, 'https://listmonk.test/api/subscribers').
      with(
        basic_auth: %w[username password],
        query: { query: "subscribers.email LIKE 'pat@example.test'" }
      ).
      to_return(status: 200, body: { data: { results: [ { id: 123 } ] } }.to_json)
    WebMock.stub_request(:delete, 'https://listmonk.test/api/subscribers/123').
      with(basic_auth: %w[username password]).
      to_return(status: 200, body: '{}')

    NewsletterService.stub(:enabled?, true) do
      NewsletterService.stub(:connection, @connection) do
        NewsletterService.unsubscribe('pat@example.test')
      end
    end

    assert_requested :delete, 'https://listmonk.test/api/subscribers/123'
  end

  test "does not use a malformed subscriber ID in the delete path" do
    WebMock.stub_request(:get, 'https://listmonk.test/api/subscribers').
      with(query: { query: "subscribers.email LIKE 'pat@example.test'" }).
      to_return(status: 200, body: { data: { results: [ { id: '../admin' } ] } }.to_json)

    NewsletterService.stub(:enabled?, true) do
      NewsletterService.stub(:connection, @connection) do
        NewsletterService.unsubscribe('pat@example.test')
      end
    end

    assert_not_requested :delete, %r{listmonk\.test}
  end
end

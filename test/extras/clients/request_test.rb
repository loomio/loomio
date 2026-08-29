require 'test_helper'

class Clients::RequestTest < ActiveSupport::TestCase
  test "sends query parameters and parses a successful JSON response" do
    WebMock.stub_request(:get, "https://example.test/profile").
      with(query: { token: "secret" }).
      to_return(status: 200, body: { name: "Pat" }.to_json)

    request = Clients::Request.new(:get, "https://example.test/profile", query: { token: "secret" })
    request.perform!(
      is_success: ->(response) { response.success? },
      success: ->(body) { body },
      failure: ->(body) { body }
    )

    assert request.success
    assert_equal({ "name" => "Pat" }, request.json)
  end

  test "encodes form request bodies" do
    WebMock.stub_request(:post, "https://example.test/token").
      with(
        headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
        body: { code: "authorization-code", grant_type: "authorization_code" }
      ).
      to_return(status: 200, body: { access_token: "access-token" }.to_json)

    request = Clients::Request.new(:post, "https://example.test/token", {
      headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
      body: { code: "authorization-code", grant_type: "authorization_code" }
    })
    request.perform!(
      is_success: ->(response) { response.success? },
      success: ->(body) { body },
      failure: ->(body) { body }
    )

    assert_equal "access-token", request.json['access_token']
  end

  test "presence of an SSL verification override disables verification" do
    previous_value = ENV['SSL_VERIFY_FALSE']
    ENV['SSL_VERIFY_FALSE'] = '0'

    request = Clients::Request.new(:get, "https://example.test", {})

    assert_equal false, request.send(:connection).ssl.verify
  ensure
    ENV['SSL_VERIFY_FALSE'] = previous_value
  end

  test "does not forward authorization headers to a redirected host" do
    WebMock.stub_request(:get, "https://example.test/profile").
      to_return(status: 302, headers: { 'Location' => 'https://identity.test/profile' })
    WebMock.stub_request(:get, "https://identity.test/profile").
      with { |request| request.headers['Authorization'].nil? }.
      to_return(status: 200, body: '{}')

    request = Clients::Request.new(:get, "https://example.test/profile", {
      headers: { 'Authorization' => 'Bearer secret-access-token' }
    })

    assert_predicate request.response, :success?
  end
end

require "test_helper"

class Clients::MatrixTest < ActiveSupport::TestCase
  setup do
    @server = "https://matrix.example.com"
    @token = "test_access_token"
    @client = Clients::Matrix.new(server: @server, access_token: @token)
  end

  def stub_join(room_id_or_alias, returned_room_id: nil)
    stub_request(:post, "#{@server}/_matrix/client/v3/join/#{CGI.escape(room_id_or_alias)}")
      .to_return(
        status: 200,
        body: {room_id: returned_room_id || room_id_or_alias}.to_json,
        headers: {"Content-Type" => "application/json"}
      )
  end

  def stub_send(room_id = nil)
    pattern = if room_id
      %r{#{Regexp.escape(@server)}/_matrix/client/v3/rooms/#{Regexp.escape(room_id)}/send/m.room.message/.+}
    else
      %r{#{Regexp.escape(@server)}/_matrix/client/v3/rooms/.+/send/m.room.message/.+}
    end
    stub_request(:put, pattern)
      .to_return(status: 200, body: {event_id: "$evt"}.to_json)
  end

  test "send_text joins room then sends m.notice" do
    room_id = "!abc123:example.com"
    stub_join(room_id)
    stub_send(room_id)

    response = @client.send_text(room_id, "hello world")

    assert_equal 200, response.code
    assert_requested(:post, "#{@server}/_matrix/client/v3/join/#{CGI.escape(room_id)}")
  end

  test "send_html joins room then sends formatted message" do
    room_id = "!abc123:example.com"
    html = "<b>Hello</b> world"
    stub_join(room_id)

    stub_request(:put, %r{#{Regexp.escape(@server)}/_matrix/client/v3/rooms/.+/send/m.room.message/.+})
      .with(body: hash_including(
        "msgtype" => "m.text",
        "format" => "org.matrix.custom.html",
        "formatted_body" => html,
        "body" => "Hello world"
      ))
      .to_return(status: 200, body: {event_id: "$evt"}.to_json)

    response = @client.send_html(room_id, html)
    assert_equal 200, response.code
  end

  test "send_text to a room alias resolves via join" do
    room_alias = "#general:example.com"
    room_id = "!resolved123:example.com"
    stub_join(room_alias, returned_room_id: room_id)
    stub_send(room_id)

    @client.send_text(room_alias, "test message")

    assert_requested(:post, "#{@server}/_matrix/client/v3/join/#{CGI.escape(room_alias)}")
    assert_requested(:put, %r{/rooms/#{Regexp.escape(room_id)}/send/})
  end

  test "join_room accepts invite to private room by ID" do
    room_id = "!private999:example.com"
    stub_join(room_id)

    result = @client.join_room(room_id)

    assert_equal room_id, result
    assert_requested(:post, "#{@server}/_matrix/client/v3/join/#{CGI.escape(room_id)}")
  end

  test "join_room accepts invite to private room by alias" do
    room_alias = "#secret:example.com"
    room_id = "!private456:example.com"
    stub_join(room_alias, returned_room_id: room_id)

    result = @client.join_room(room_alias)

    assert_equal room_id, result
  end

  test "sending to a private room works end to end" do
    room_id = "!private789:example.com"
    stub_join(room_id)
    stub_send(room_id)

    @client.send_html(room_id, "<p>Secret message</p>")

    assert_requested(:post, "#{@server}/_matrix/client/v3/join/#{CGI.escape(room_id)}")
    assert_requested(:put, %r{/rooms/#{Regexp.escape(room_id)}/send/})
  end

  test "server url with trailing slash is handled" do
    client = Clients::Matrix.new(server: "https://matrix.example.com/", access_token: @token)
    room_id = "!abc:example.com"

    stub_request(:post, %r{https://matrix.example.com/_matrix/client/v3/join/.+})
      .to_return(status: 200, body: {room_id: room_id}.to_json, headers: {"Content-Type" => "application/json"})
    stub_request(:put, %r{https://matrix.example.com/_matrix/client/v3/rooms/.+/send/m.room.message/.+})
      .to_return(status: 200, body: {event_id: "$evt"}.to_json)

    client.send_text(room_id, "trailing slash test")

    assert_not_requested(:post, %r{https://matrix.example.com//_matrix})
    assert_not_requested(:put, %r{https://matrix.example.com//_matrix})
  end
end

require "test_helper"
require_relative "support"

class Hocuspocus::ServerTest < ActiveSupport::TestCase
  include HocuspocusTestSupport

  P = Hocuspocus::Protocol

  setup do
    @updates = VECTORS["scenarios"].find { |scenario| scenario["name"] == "two clients" }["updates"].map { |update| vector_bytes(update) }
    @server = build_server do |config|
      config.authenticate = lambda do |document_name:, env:|
        raise "auth backend down" if env[:user] == "error"

        env[:user] == "member" && !document_name.start_with?("secret")
      end
    end
  end

  test "authenticates, syncs and broadcasts updates to the other clients" do
    alice, alice_socket = connect(@server, user: "member")
    bob, bob_socket = connect(@server, user: "member")
    [alice, bob].each { |client| client.receive(auth_message("doc")) }
    assert_equal ["doc", :auth, P::AUTH_AUTHENTICATED, "read-write"], alice_socket.decoded.first

    alice.receive(sync_message("doc", P::SYNC_UPDATE, @updates.first))
    assert_includes alice_socket.decoded, ["doc", :sync_status, 1]
    assert_includes bob_socket.decoded, ["doc", :sync, P::SYNC_UPDATE, @updates.first]

    carol, carol_socket = connect(@server, user: "member")
    carol.receive(auth_message("doc"))
    carol.receive(sync_message("doc", P::SYNC_STEP1, Hocuspocus::Yjs.encode_state_vector([])))
    step1, step2 = carol_socket.decoded.last(2)
    assert_equal ["doc", :sync, P::SYNC_STEP1], step1.first(3)
    assert_equal ["doc", :sync, P::SYNC_STEP2], step2.first(3)
    assert_equal Hocuspocus::Yjs.encode_state_vector_from_update(@updates.first), Hocuspocus::Yjs.encode_state_vector_from_update(step2.last)
  end

  test "does not rebroadcast content the document already has" do
    alice, = connect(@server, user: "member")
    bob, bob_socket = connect(@server, user: "member")
    [alice, bob].each { |client| client.receive(auth_message("doc")) }
    alice.receive(sync_message("doc", P::SYNC_UPDATE, @updates.first))
    bob_socket.clear

    alice.receive(sync_message("doc", P::SYNC_STEP2, @updates.first))
    assert_empty bob_socket.decoded.select { |message| message[1] == :sync }
  end

  test "denies documents the user may not open, and failing checks" do
    [[{ user: "member" }, "secret-doc"], [{ user: "stranger" }, "doc"], [{ user: "error" }, "doc"]].each do |env, name|
      client, socket = connect(@server, env)
      client.receive(auth_message(name))
      client.receive(sync_message(name, P::SYNC_UPDATE, @updates.first))
      assert_equal [[name, :auth, P::AUTH_PERMISSION_DENIED, "permission-denied"]], socket.decoded
    end
    assert_empty @server.documents
  end

  test "drops messages for documents that are not open" do
    client, socket = connect(@server, user: "member")
    client.receive(sync_message("doc", P::SYNC_UPDATE, @updates.first))
    assert_empty socket.messages
    assert_empty @server.documents
  end

  test "keeps documents on one socket apart" do
    client, socket = connect(@server, user: "member")
    client.receive(auth_message("one"))
    client.receive(auth_message("two"))
    client.receive(sync_message("one", P::SYNC_UPDATE, @updates.first))

    assert_includes socket.decoded, ["one", :sync_status, 1]
    assert_equal Hocuspocus::Yjs::EMPTY_UPDATE, @server.documents["two"].state
  end

  test "relays awareness and clears it when the client leaves" do
    alice, = connect(@server, user: "member")
    bob, bob_socket = connect(@server, user: "member")
    [alice, bob].each { |client| client.receive(auth_message("doc")) }
    alice.receive(awareness_message("doc", 42, 1, { "user" => "Alice" }))
    assert(bob_socket.decoded.any? { |message| message[1] == :awareness })

    bob_socket.clear
    alice.socket_closed
    removal = bob_socket.decoded.find { |message| message[1] == :awareness }
    peer = Hocuspocus::Awareness.new
    peer.apply(awareness_update(42, 1, { "user" => "Alice" }))
    assert_equal [[], [], [42]], peer.apply(removal.last)
  end

  test "unloads a document when its last connection closes" do
    alice, = connect(@server, user: "member")
    bob, = connect(@server, user: "member")
    [alice, bob].each { |client| client.receive(auth_message("doc")) }

    alice.socket_closed
    assert @server.documents.key?("doc")
    bob.receive(client_message("doc", P::CLOSE))
    assert_empty @server.documents
  end

  test "closes sockets that send malformed messages" do
    client, socket = connect(@server, user: "member")
    client.receive("\xff".b)
    assert_equal [P::UNAUTHORIZED.code, P::UNAUTHORIZED.reason], socket.closed_with
  end

  test "times out sockets that never open a document" do
    client, socket = connect(@server, user: "member")
    client.check_timeout(Process.clock_gettime(Process::CLOCK_MONOTONIC) + 31)
    assert_equal P::CONNECTION_TIMEOUT.code, socket.closed_with.first
  end

  test "stop disconnects everyone and refuses connections until start" do
    client, socket = connect(@server, user: "member")
    client.receive(auth_message("doc"))
    @server.stop(wait: 0)
    assert_equal P::GOING_AWAY.code, socket.closed_with.first
    assert_empty @server.documents
    assert_equal 503, @server.call(websocket_env).first

    @server.start
    assert_equal 501, @server.call(websocket_env).first # passes the checks; the test env cannot hijack
  end

  test "checks the origin before accepting a WebSocket" do
    server = build_server { |config| config.allowed_origin = ->(origin) { origin == "https://loomio.test" } }
    assert_equal 403, server.call(websocket_env("HTTP_ORIGIN" => "https://evil.test")).first
    assert_equal 403, server.call(websocket_env).first
    assert_equal 501, server.call(websocket_env("HTTP_ORIGIN" => "https://loomio.test")).first
    assert_equal 426, server.call({ "REQUEST_METHOD" => "GET" }).first
  end

  test "shares documents between server processes through pub/sub" do
    pubsub = FakePubSub.new
    first = build_server(pubsub: pubsub)
    second = build_server(pubsub: pubsub)

    alice, = connect(first)
    alice.receive(auth_message("doc"))
    alice.receive(sync_message("doc", P::SYNC_UPDATE, @updates.first))

    # A process loading the document asks the others for their state.
    bob, bob_socket = connect(second)
    bob.receive(auth_message("doc"))
    assert_equal first.documents["doc"].state_vector, second.documents["doc"].state_vector

    alice.receive(sync_message("doc", P::SYNC_UPDATE, @updates.second))
    assert_includes bob_socket.decoded, ["doc", :sync, P::SYNC_UPDATE, @updates.second]
  end

  private

  def websocket_env(extra = {})
    { "REQUEST_METHOD" => "GET", "HTTP_CONNECTION" => "Upgrade", "HTTP_UPGRADE" => "websocket" }.merge(extra)
  end

  def awareness_update(client_id, clock, state)
    encoder = Hocuspocus::Lib0::Encoder.new
    encoder.write_var_uint(1).write_var_uint(client_id).write_var_uint(clock).write_var_string(JSON.generate(state))
    encoder.to_s
  end
end

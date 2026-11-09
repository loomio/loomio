require "base64"
require_relative "../../../lib/collab_server"

module CollabServerTestSupport
  # Yjs's own results for random edits (see generate_yjs_vectors.mjs). They
  # are generated into tmp/ rather than committed, and regenerated when Yjs in
  # vue/node_modules or the generator changes.
  def self.load_vectors
    path = Rails.root.join("tmp/collab_server/yjs_vectors.json")
    generator = File.read(File.expand_path("generate_yjs_vectors.mjs", __dir__))
    yjs_package = Rails.root.join("vue/node_modules/yjs/package.json")
    unless yjs_package.exist?
      raise "Yjs test vectors need the Vue client's packages: run npm ci in vue/"
    end

    yjs_version = JSON.parse(yjs_package.read)["version"]
    vectors = JSON.parse(path.read) if path.exist?
    if vectors.nil? || vectors["yjs"] != yjs_version || vectors["generator"] != generator
      system("node", File.expand_path("generate_yjs_vectors.mjs", __dir__), path.to_s, exception: true)
      vectors = JSON.parse(path.read)
    end
    vectors
  end

  VECTORS = load_vectors

  class ImmediateExecutor
    def post
      yield
    end
  end

  class FakeSocket
    attr_reader :messages, :closed_with

    def initialize
      @messages = []
      @closed_with = nil
    end

    def send_binary(message)
      @messages << message
    end

    def close(code, reason)
      @closed_with = [code, reason]
    end

    def check_closing(_now); end

    # Decodes sent messages as [address, type, sub_type_or_payload, ...].
    def decoded
      messages.map do |message|
        decoder = CollabServer::Lib0::Decoder.new(message)
        address = decoder.read_var_string
        type = decoder.read_var_uint
        case type
        when CollabServer::Protocol::SYNC then [address, :sync, decoder.read_var_uint, decoder.read_var_uint8_array]
        when CollabServer::Protocol::AWARENESS then [address, :awareness, decoder.read_var_uint8_array]
        when CollabServer::Protocol::AUTH then [address, :auth, decoder.read_var_uint, decoder.read_var_string]
        when CollabServer::Protocol::SYNC_STATUS then [address, :sync_status, decoder.read_var_uint]
        when CollabServer::Protocol::CLOSE then [address, :close, decoder.read_var_string]
        else [address, type]
        end
      end
    end

    def clear
      @messages.clear
    end
  end

  # A pub/sub adapter shared by several servers. Messages reach only active
  # subscriptions. With `deferred: true`, subscriptions stay inactive until
  # #activate_next, as real adapters activate them some time after subscribe.
  class FakePubSub
    def initialize(deferred: false)
      @deferred = deferred
      @active = Hash.new { |hash, key| hash[key] = [] }
      @pending = []
    end

    def subscribe(channel, callback, success_callback = nil)
      @pending << [channel, callback, success_callback]
      activate_next unless @deferred
    end

    def activate_next
      channel, callback, success_callback = @pending.shift
      @active[channel] << callback
      success_callback&.call
    end

    def unsubscribe(channel, callback)
      @active[channel].delete(callback)
    end

    def subscriptions_count
      @active.values.sum(&:size) + @pending.size
    end

    # Makes broadcasts raise, as during a Redis or database outage.
    attr_writer :failing

    # Runs once, just before the next greeting is delivered.
    attr_writer :before_hello

    def broadcast(channel, payload)
      raise IOError, "pub/sub unavailable" if @failing

      if @before_hello && JSON.parse(payload)["t"] == "hello"
        hook = @before_hello
        @before_hello = nil
        hook.call
      end

      @active[channel].dup.each { |callback| callback.call(payload) }
    end
  end

  def vector_bytes(value)
    Base64.decode64(value).b
  end

  def build_server(pubsub: nil, &configure)
    config = CollabServer::Configuration.new
    config.executor = ImmediateExecutor.new
    config.pubsub = pubsub
    configure&.call(config)
    CollabServer::Server.new(config)
  end

  def connect(server, env = {})
    socket = FakeSocket.new
    client = CollabServer::ClientConnection.new(server: server, socket: socket, env: env)
    server.client_opened(client)
    [client, socket]
  end

  def client_message(address, type)
    encoder = CollabServer::Lib0::Encoder.new
    encoder.write_var_string(address)
    encoder.write_var_uint(type)
    yield encoder if block_given?
    encoder.to_s
  end

  def auth_message(address, token = "")
    client_message(address, CollabServer::Protocol::AUTH) do |encoder|
      encoder.write_var_uint(0) # a token
      encoder.write_var_string(token)
      encoder.write_var_string("4.8.0")
    end
  end

  def sync_message(address, sub_type, bytes)
    client_message(address, CollabServer::Protocol::SYNC) do |encoder|
      encoder.write_var_uint(sub_type)
      encoder.write_var_uint8_array(bytes)
    end
  end

  def awareness_message(address, client_id, clock, state)
    update = CollabServer::Lib0::Encoder.new
    update.write_var_uint(1).write_var_uint(client_id).write_var_uint(clock).write_var_string(JSON.generate(state))
    client_message(address, CollabServer::Protocol::AWARENESS) { |encoder| encoder.write_var_uint8_array(update.to_s) }
  end
end

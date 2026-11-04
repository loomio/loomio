require "base64"
require_relative "../../../lib/hocuspocus"

module HocuspocusTestSupport
  VECTORS = JSON.parse(File.read(File.expand_path("yjs_vectors.json", __dir__)))

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
        decoder = Hocuspocus::Lib0::Decoder.new(message)
        address = decoder.read_var_string
        type = decoder.read_var_uint
        case type
        when Hocuspocus::Protocol::SYNC then [address, :sync, decoder.read_var_uint, decoder.read_var_uint8_array]
        when Hocuspocus::Protocol::AWARENESS then [address, :awareness, decoder.read_var_uint8_array]
        when Hocuspocus::Protocol::AUTH then [address, :auth, decoder.read_var_uint, decoder.read_var_string]
        when Hocuspocus::Protocol::SYNC_STATUS then [address, :sync_status, decoder.read_var_uint]
        when Hocuspocus::Protocol::CLOSE then [address, :close, decoder.read_var_string]
        else [address, type]
        end
      end
    end

    def clear
      @messages.clear
    end
  end

  # Delivers synchronously, like a pub/sub adapter shared by several servers.
  class FakePubSub
    def initialize
      @subscribers = Hash.new { |hash, key| hash[key] = [] }
    end

    def subscribe(channel, callback, success_callback = nil)
      @subscribers[channel] << callback
      success_callback&.call
    end

    def unsubscribe(channel, callback)
      @subscribers[channel].delete(callback)
    end

    def broadcast(channel, payload)
      @subscribers[channel].dup.each { |callback| callback.call(payload) }
    end
  end

  def vector_bytes(value)
    Base64.decode64(value).b
  end

  def build_server(pubsub: nil, &configure)
    config = Hocuspocus::Configuration.new
    config.executor = ImmediateExecutor.new
    config.pubsub = pubsub
    configure&.call(config)
    Hocuspocus::Server.new(config)
  end

  def connect(server, env = {})
    socket = FakeSocket.new
    client = Hocuspocus::ClientConnection.new(server: server, socket: socket, env: env)
    server.client_opened(client)
    [client, socket]
  end

  def client_message(address, type)
    encoder = Hocuspocus::Lib0::Encoder.new
    encoder.write_var_string(address)
    encoder.write_var_uint(type)
    yield encoder if block_given?
    encoder.to_s
  end

  def auth_message(address, token = "")
    client_message(address, Hocuspocus::Protocol::AUTH) do |encoder|
      encoder.write_var_uint(0) # a token
      encoder.write_var_string(token)
      encoder.write_var_string("4.8.0")
    end
  end

  def sync_message(address, sub_type, bytes)
    client_message(address, Hocuspocus::Protocol::SYNC) do |encoder|
      encoder.write_var_uint(sub_type)
      encoder.write_var_uint8_array(bytes)
    end
  end

  def awareness_message(address, client_id, clock, state)
    update = Hocuspocus::Lib0::Encoder.new
    update.write_var_uint(1).write_var_uint(client_id).write_var_uint(clock).write_var_string(JSON.generate(state))
    client_message(address, Hocuspocus::Protocol::AWARENESS) { |encoder| encoder.write_var_uint8_array(update.to_s) }
  end
end

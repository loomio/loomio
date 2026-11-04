# frozen_string_literal: true

require "rack"
require "socket"
require "websocket/driver"

module Hocuspocus
  # A WebSocket taken over from the Rack server with a full hijack. The
  # websocket-driver gem handles framing; the Reactor does the socket IO.
  class WebSocket
    CLOSE_GRACE = 5 # seconds to wait for the client to acknowledge a close

    attr_reader :env, :url

    def initialize(server, env)
      @server = server
      @env = env
      request = ::Rack::Request.new(env)
      @url = "#{request.ssl? ? 'wss' : 'ws'}://#{request.host_with_port}#{request.fullpath}"
      @driver = ::WebSocket::Driver.rack(self, max_length: server.config.message_size_max, binary_data_format: :string)
      @driver_mutex = Mutex.new
      @write_mutex = Mutex.new
      @state_mutex = Mutex.new
      @write_buffer = String.new(encoding: Encoding::BINARY)
      @closed = false
      @closing_since = nil
      @client = ClientConnection.new(server: server, socket: self, env: env)

      @inbox = []
      # Hocuspocus speaks binary frames only.
      @driver.on(:message) { |event| @inbox << event.data if event.data.encoding == Encoding::BINARY }
      @driver.on(:close) { shutdown }
    end

    attr_reader :client

    def start
      @io = env["rack.hijack"].call
      @io = env["rack.hijack_io"] unless @io.respond_to?(:read_nonblock)
      # Send small frames immediately. Without this, Nagle's algorithm holds
      # each frame until the previous one is acknowledged, which delayed
      # edits by hundreds of milliseconds under load. Node's ws does the same.
      @io.setsockopt(::Socket::IPPROTO_TCP, ::Socket::TCP_NODELAY, 1) if @io.respond_to?(:setsockopt)
      @server.reactor.attach(@io, self)
      @driver_mutex.synchronize { @driver.start }
    end

    def send_binary(message)
      return if closed?

      @driver_mutex.synchronize { @driver.binary(message) }
    end

    def close(code, reason)
      return if closed?

      @state_mutex.synchronize { @closing_since ||= monotonic_now }
      @driver_mutex.synchronize { @driver.close(reason, code) }
    end

    # Drops a socket whose client never acknowledged our close frame.
    def check_closing(now)
      closing_since = @state_mutex.synchronize { @closing_since }
      shutdown if closing_since && now - closing_since > CLOSE_GRACE
    end

    def closed?
      @state_mutex.synchronize { @closed }
    end

    # Reactor callbacks.

    # Messages are handed to the client after the driver lock is released,
    # because handling one may send on this socket.
    def parse(data)
      messages = @driver_mutex.synchronize do
        @driver.parse(data)
        @inbox.slice!(0..)
      end
      messages.each { |message| @client.receive(message) }
    end

    def io_closed
      shutdown
    end

    # Called by the driver to send frames. Frames are buffered, and the
    # reactor writes the whole buffer with one syscall when the socket is
    # writable. Broadcasts run while a document is locked, so they must not
    # wait on the network, and batching keeps busy documents to one write per
    # socket per reactor turn.
    def write(data)
      schedule = @write_mutex.synchronize do
        was_empty = @write_buffer.empty?
        @write_buffer << data
        was_empty
      end
      @server.reactor.writes_pending(@io) if schedule
    end

    # Returns true once the buffer is empty.
    def flush_write_buffer
      @write_mutex.synchronize do
        return true if @write_buffer.empty?

        written = @io.write_nonblock(@write_buffer, exception: false)
        return false unless written.is_a?(Integer)

        @write_buffer = written == @write_buffer.bytesize ? String.new(encoding: Encoding::BINARY) : @write_buffer.byteslice(written..)
        @write_buffer.empty?
      end
    end

    private

    def shutdown
      @state_mutex.synchronize do
        return if @closed

        @closed = true
      end
      begin
        flush_write_buffer
      rescue IOError, SystemCallError
        nil
      end
      @server.reactor.detach(@io)
      @client.socket_closed
      @server.client_closed(@client)
    end

    def monotonic_now
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end
end

# frozen_string_literal: true

# Ported from @hocuspocus/server (https://github.com/ueberdosis/hocuspocus), MIT licence, copyright (c) 2023 Tiptap GmbH.
# See LICENSE-THIRD-PARTY.

module Hocuspocus
  # One WebSocket, which can carry several documents. A client opens a
  # document by sending an Auth message for it; the provider always sends that
  # first, and messages are handled in order, so anything that arrives for a
  # document that is not open is dropped.
  #
  # Message handling runs on the socket's serial queue, one message at a time,
  # so the state here needs no lock.
  class ClientConnection
    def initialize(server:, socket:, env:)
      @server = server
      @socket = socket
      @env = env
      @queue = SerialQueue.new(server.executor, ->(error) { server.report(error, document: nil) })
      @connections = {}
      @opened_at = monotonic_now
      @last_message_at = @opened_at
      @terminated = false
    end

    # Called by the socket for each binary message.
    def receive(data)
      @last_message_at = monotonic_now
      @queue.post { handle_message(data) }
    end

    # Called by the socket once it has closed.
    def socket_closed
      @queue.post { close_all(Protocol::NORMAL) }
    end

    def shut_down
      @queue.post { terminate(Protocol::GOING_AWAY) }
    end

    # Called periodically. Until a document opens, the deadline counts from
    # when the socket opened, so traffic alone cannot keep it alive.
    def check_timeout(now)
      @socket.check_closing(now)
      reference = @connections.empty? ? @opened_at : @last_message_at
      @queue.post { terminate(Protocol::CONNECTION_TIMEOUT) } if now - reference > @server.config.timeout
    end

    def send_message(message)
      @socket.send_binary(message)
    end

    def close_document(connection, event)
      return unless connection.close(event)

      @connections.delete(connection.document.name)
      @server.detach(connection)
    end

    private

    def handle_message(data)
      return if @terminated
      # Provider 4.x answers a server Ping with a bare Pong. The server never
      # pings, but a stray Pong must not be read as a document name.
      return if data.bytesize == 1 && data.getbyte(0) == Protocol::PONG

      decoder = Lib0::Decoder.new(data)
      name = decoder.read_var_string
      if (connection = @connections[name])
        handle_document_message(connection, decoder)
      elsif decoder.read_var_uint == Protocol::AUTH
        open_document(name)
      end
    rescue Lib0::DecodeError => e
      @server.logger&.warn("hocuspocus: closing socket after an invalid message: #{e.message}")
      terminate(Protocol::UNAUTHORIZED)
    end

    def handle_document_message(connection, decoder)
      connection.handle(decoder)
    rescue Lib0::DecodeError => e
      @server.logger&.warn("hocuspocus: closing #{connection.document.name} after an invalid message: #{e.message}")
      close_document(connection, Protocol::RESET_CONNECTION)
    end

    # The Auth message carries a token, which is ignored: `authenticate`
    # identifies the client from the upgrade request instead.
    def open_document(name)
      unless @server.authenticate(name, @env)
        send_message(Protocol.permission_denied(name))
        return
      end

      send_message(Protocol.authenticated(name))
      @connections[name] = @server.attach(self, name)
    end

    def terminate(event)
      return if @terminated

      close_all(event)
      @socket.close(event.code, event.reason)
    end

    def close_all(event)
      @terminated = true
      @connections.each_value { |connection| @server.detach(connection) if connection.close(event) }
      @connections.clear
    end

    def monotonic_now
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end
end

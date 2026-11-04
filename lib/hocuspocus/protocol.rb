# frozen_string_literal: true

# Ported from @hocuspocus/server (https://github.com/ueberdosis/hocuspocus), MIT licence, copyright (c) 2023 Tiptap GmbH.
# See LICENSE-THIRD-PARTY.

module Hocuspocus
  # Message framing of the Hocuspocus protocol (@hocuspocus/server 4.x). Each
  # message starts with the document name, then a message type. Several
  # documents can share one WebSocket.
  module Protocol
    SYNC = 0
    AWARENESS = 1
    AUTH = 2
    QUERY_AWARENESS = 3
    SYNC_REPLY = 4 # SYNC, as answered by the server
    CLOSE = 7
    SYNC_STATUS = 8
    PONG = 10

    SYNC_STEP1 = 0
    SYNC_STEP2 = 1
    SYNC_UPDATE = 2

    AUTH_PERMISSION_DENIED = 1
    AUTH_AUTHENTICATED = 2

    CloseEvent = Data.define(:code, :reason)
    NORMAL = CloseEvent.new(1000, "Server closed the connection")
    GOING_AWAY = CloseEvent.new(1001, "Going Away")
    RESET_CONNECTION = CloseEvent.new(4205, "Reset Connection")
    UNAUTHORIZED = CloseEvent.new(4401, "Unauthorized")
    CONNECTION_TIMEOUT = CloseEvent.new(4408, "Connection Timeout")

    module_function

    def message(name, type)
      encoder = Lib0::Encoder.new
      encoder.write_var_string(name)
      encoder.write_var_uint(type)
      yield encoder if block_given?
      encoder.to_s
    end

    def sync(name, step, bytes)
      message(name, SYNC) do |encoder|
        encoder.write_var_uint(step)
        encoder.write_var_uint8_array(bytes)
      end
    end

    def sync_status(name, applied)
      message(name, SYNC_STATUS) { |encoder| encoder.write_var_uint(applied ? 1 : 0) }
    end

    def awareness(name, update)
      message(name, AWARENESS) { |encoder| encoder.write_var_uint8_array(update) }
    end

    def authenticated(name)
      message(name, AUTH) do |encoder|
        encoder.write_var_uint(AUTH_AUTHENTICATED)
        encoder.write_var_string("read-write")
      end
    end

    def permission_denied(name)
      message(name, AUTH) do |encoder|
        encoder.write_var_uint(AUTH_PERMISSION_DENIED)
        encoder.write_var_string("permission-denied")
      end
    end

    def close(name, reason)
      message(name, CLOSE) { |encoder| encoder.write_var_string(reason) }
    end
  end
end

# frozen_string_literal: true

# Ported from @hocuspocus/server (https://github.com/ueberdosis/hocuspocus), MIT licence, copyright (c) 2023 Tiptap GmbH.
# See LICENSE-THIRD-PARTY.

module CollabServer
  # An authenticated client's link to one document over a shared WebSocket.
  # Messages arrive in order from the owning ClientConnection.
  class Connection
    attr_reader :document

    def initialize(server:, client:, document:)
      @server = server
      @client = client
      @document = document
    end

    def send(message)
      @client.send_message(message)
    end

    # Handles one message for this document; the name has been read.
    def handle(decoder)
      case decoder.read_var_uint
      when Protocol::SYNC, Protocol::SYNC_REPLY then handle_sync(decoder)
      when Protocol::AWARENESS
        update = document.apply_awareness(decoder.read_var_uint8_array, self)
        @server.publish(document, "awareness", update) if update
      when Protocol::QUERY_AWARENESS
        update = document.awareness_update
        send(Protocol.awareness(document.name, update)) if update
      when Protocol::CLOSE then @client.close_document(self, Protocol::CloseEvent.new(1000, "provider_initiated"))
      end
      # Other types (a repeated Auth, stateless messages) need no answer.
    end

    # Detaches from the document and tells the client. Returns false when the
    # connection was already closed.
    def close(event)
      return false unless document.connection?(self)

      update = document.remove_connection(self)
      @server.publish(document, "awareness", update) if update
      send(Protocol.close(document.name, event.reason))
      true
    end

    private

    # y-protocols sync: answer SyncStep1 with our state vector and what the
    # client lacks; apply SyncStep2 and Update messages.
    def handle_sync(decoder)
      step = decoder.read_var_uint
      bytes = decoder.read_var_uint8_array
      case step
      when Protocol::SYNC_STEP1
        send(Protocol.sync(document.name, Protocol::SYNC_STEP1, document.state_vector))
        send(Protocol.sync(document.name, Protocol::SYNC_STEP2, document.diff(bytes)))
      when Protocol::SYNC_STEP2, Protocol::SYNC_UPDATE
        delta = document.apply_update(bytes)
        @server.publish(document, "update", delta) if delta
        send(Protocol.sync_status(document.name, true))
      else
        raise Lib0::DecodeError, "unknown sync message type"
      end
    end
  end
end

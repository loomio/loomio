# frozen_string_literal: true

module CollabServer
  class Configuration
    # Called with (document_name:, env:) for each document a client opens,
    # where env is the Rack env of the WebSocket upgrade request. Return true
    # to allow the client to read and edit the document.
    attr_accessor :authenticate
    # Called with the upgrade request's Origin header (nil when absent).
    # Browsers attach cookies to WebSocket requests from any site, so check it
    # when `authenticate` trusts cookies. nil accepts every origin.
    attr_accessor :allowed_origin
    # Wraps calls into the application, e.g. Rails.application.executor.wrap.
    attr_accessor :wrapper
    # Receives (exception, context_hash).
    attr_accessor :error_handler
    # An Action Cable pub/sub adapter (subscribe, unsubscribe, broadcast).
    # Needed when several server processes accept connections.
    attr_accessor :pubsub
    # Anything with #post(&block); defaults to a pool of `threads` threads.
    attr_accessor :executor
    attr_accessor :logger, :timeout, :threads, :message_size_max

    def initialize
      @authenticate = ->(**) { true }
      @wrapper = ->(&block) { block.call }
      @timeout = 30 # seconds without messages before a socket is closed
      @threads = 4
      @message_size_max = 16 * 1024 * 1024
    end
  end
end

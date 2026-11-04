# frozen_string_literal: true

require_relative "hocuspocus/lib0"
require_relative "hocuspocus/yjs"
require_relative "hocuspocus/awareness"
require_relative "hocuspocus/protocol"
require_relative "hocuspocus/configuration"
require_relative "hocuspocus/serial_queue"
require_relative "hocuspocus/document"
require_relative "hocuspocus/connection"
require_relative "hocuspocus/client_connection"
require_relative "hocuspocus/reactor"
require_relative "hocuspocus/web_socket"
require_relative "hocuspocus/server"

# A Ruby server for the Hocuspocus collaboration protocol, compatible with
# @hocuspocus/provider 4.x. It runs inside the Rails app as a Rack endpoint and
# relays Yjs documents between the browsers editing them; it does not persist
# documents. See LICENSE-THIRD-PARTY for the projects it is ported from.
module Hocuspocus
  class << self
    def config
      @config ||= Configuration.new
    end

    def configure
      yield config
    end

    def server
      @server ||= Server.new(config)
    end
  end
end

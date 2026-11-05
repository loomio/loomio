# frozen_string_literal: true

require_relative "collab_server/lib0"
require_relative "collab_server/yjs"
require_relative "collab_server/awareness"
require_relative "collab_server/protocol"
require_relative "collab_server/configuration"
require_relative "collab_server/serial_queue"
require_relative "collab_server/document"
require_relative "collab_server/connection"
require_relative "collab_server/client_connection"
require_relative "collab_server/reactor"
require_relative "collab_server/web_socket"
require_relative "collab_server/server"

# A Ruby server for the Hocuspocus collaboration protocol, compatible with
# @hocuspocus/provider 4.x. It runs inside the Rails app as a Rack endpoint and
# relays Yjs documents between the browsers editing them; it does not persist
# documents. See LICENSE-THIRD-PARTY for the projects it is ported from.
module CollabServer
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

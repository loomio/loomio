# frozen_string_literal: true

require "base64"
require "concurrent"
require "json"
require "securerandom"

module Hocuspocus
  # The Rack endpoint that accepts WebSockets, the registry of documents in
  # memory, and a ticker for idle sockets and stale awareness.
  #
  # Threads and pub/sub subscriptions start on first use, and again in a
  # forked child, so the server works under preforking Puma. Each process
  # holds its own documents; pub/sub keeps processes holding the same document
  # in step.
  class Server
    TICK = 1 # seconds
    AWARENESS_SWEEP = 3 # seconds, as in y-protocols

    attr_reader :config

    def initialize(config = Configuration.new)
      @config = config
      @start_mutex = Mutex.new
      @pid = nil
    end

    def logger
      config.logger
    end

    # Rack interface.
    def call(env)
      ensure_started
      return text_response(426, "Upgrade Required") unless ::WebSocket::Driver.websocket?(env)
      return text_response(503, "Stopped") unless @accepting
      return text_response(403, "Origin not allowed") if config.allowed_origin && !config.allowed_origin.call(env["HTTP_ORIGIN"])
      return text_response(501, "WebSocket hijacking unsupported") unless env["rack.hijack"]

      socket = WebSocket.new(self, env)
      client_opened(socket.client)
      socket.start
      [-1, {}, []]
    end

    def executor
      ensure_started
      @executor
    end

    def reactor
      ensure_started
      @start_mutex.synchronize { @reactor ||= Reactor.new(logger) }
    end

    def documents
      ensure_started
      @mutex.synchronize { @documents.dup }
    end

    # Disconnects every client and refuses new ones until #start; documents
    # unload as their connections close. Waits up to `wait` seconds for that.
    def stop(wait: 5)
      ensure_started
      clients = @mutex.synchronize do
        @accepting = false
        @clients.to_a
      end
      clients.each(&:shut_down)
      deadline = monotonic_now + wait
      sleep 0.05 while @mutex.synchronize { @documents.any? } && monotonic_now < deadline
    end

    def start
      ensure_started
      @mutex.synchronize { @accepting = true }
    end

    # Errors deny access rather than leaving the client waiting.
    def authenticate(document_name, env)
      config.wrapper.call { config.authenticate.call(document_name: document_name, env: env) } ? true : false
    rescue StandardError => e
      report(e, document: document_name)
      false
    end

    # Lock order is registry, then document, here and in #detach.
    def attach(client, document_name)
      created = false
      connection = @mutex.synchronize do
        document = @documents[document_name] ||= begin
          created = true
          Document.new(document_name)
        end
        Connection.new(server: self, client: client, document: document).tap { |conn| document.add_connection(conn) }
      end
      subscribe(connection.document) if created
      connection
    end

    # Unloads the document once nobody is connected to it.
    def detach(connection)
      document = connection.document
      unloaded = @mutex.synchronize do
        next false unless @documents[document.name].equal?(document) && document.idle?

        @documents.delete(document.name)
      end
      unsubscribe(document) if unloaded
    end

    def client_opened(client)
      ensure_started
      @mutex.synchronize { @clients << client }
    end

    def client_closed(client)
      @mutex.synchronize { @clients.delete(client) }
    end

    def report(exception, context = {})
      logger&.error("hocuspocus: #{exception.class}: #{exception.message} #{context.inspect}")
      config.error_handler&.call(exception, context)
    end

    # Cross-process fan-out. Each process subscribes to a channel per loaded
    # document. A newly loaded document asks the others for their state, and
    # local updates and awareness changes are relayed to them. Remote messages
    # are applied in order on a per-document queue; the CRDT makes duplicates
    # and reordering between processes harmless.
    def publish(document, type, data)
      return unless config.pubsub

      payload = JSON.generate("o" => @process_id, "t" => type, "d" => Base64.strict_encode64(data))
      config.pubsub.broadcast(channel(document), payload)
    rescue StandardError => e
      report(e, document: document.name)
    end

    private

    def ensure_started
      return if @pid == Process.pid

      @start_mutex.synchronize do
        return if @pid == Process.pid

        @mutex = Mutex.new
        @documents = {}
        @clients = Set.new
        @subscriptions = {}
        @accepting = true
        @process_id = SecureRandom.hex(8)
        @executor = config.executor ||
          Concurrent::ThreadPoolExecutor.new(name: "hocuspocus", min_threads: 1, max_threads: config.threads, max_queue: 0)
        @reactor = nil
        @ticker = Thread.new { tick_forever }
        @ticker.name = "hocuspocus-ticker"
        @pid = Process.pid
      end
    end

    def tick_forever
      last_sweep = monotonic_now
      loop do
        sleep TICK
        now = monotonic_now
        clients, documents = @mutex.synchronize { [@clients.to_a, @documents.values] }
        clients.each { |client| client.check_timeout(now) }
        next if now - last_sweep < AWARENESS_SWEEP

        last_sweep = now
        documents.each do |document|
          update = document.expire_awareness
          publish(document, "awareness", update) if update
        end
      rescue StandardError => e
        report(e, thread: "ticker")
      end
    end

    def channel(document)
      "hocuspocus:#{document.name}"
    end

    def subscribe(document)
      return unless config.pubsub

      queue = SerialQueue.new(@executor, ->(error) { report(error, document: document.name) })
      callback = ->(payload) { queue.post { receive_remote(document, payload) } }
      @mutex.synchronize { @subscriptions[document] = callback }
      config.pubsub.subscribe(channel(document), callback, -> { publish(document, "query", "") })
    rescue StandardError => e
      report(e, document: document.name)
    end

    def unsubscribe(document)
      callback = @mutex.synchronize { @subscriptions.delete(document) }
      config.pubsub.unsubscribe(channel(document), callback) if callback
    rescue StandardError => e
      report(e, document: document.name)
    end

    def receive_remote(document, payload)
      message = JSON.parse(payload)
      return if message["o"] == @process_id

      data = Base64.strict_decode64(message["d"])
      case message["t"]
      when "update" then document.apply_update(data)
      when "awareness" then document.apply_awareness(data)
      when "query"
        publish(document, "update", document.state)
        awareness = document.awareness_update
        publish(document, "awareness", awareness) if awareness
      end
    end

    def text_response(status, text)
      [status, { "content-type" => "text/plain" }, [text]]
    end

    def monotonic_now
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end
end

# frozen_string_literal: true

require "nio"

module Hocuspocus
  # A single thread that reads from and writes to every hijacked socket of the
  # process, modelled on Action Cable's StreamEventLoop. Sockets parse frames
  # on this thread but hand messages to their serial queues, so slow work never
  # blocks other sockets' IO.
  class Reactor
    READ_CHUNK = 16 * 1024

    def initialize(logger)
      @logger = logger
      @selector = NIO::Selector.new
      @mutex = Mutex.new
      @todo = []
      @pending_writes = []
      @woken = false
      @monitors = {}
      @read_buffer = String.new(capacity: READ_CHUNK, encoding: Encoding::BINARY)
      @thread = Thread.new { run }
      @thread.name = "hocuspocus-reactor"
    end

    def attach(io, socket)
      schedule do
        monitor = @selector.register(io, :r)
        monitor.value = socket
        @monitors[io] = monitor
      end
    end

    def detach(io)
      schedule do
        @selector.deregister(io)
        @monitors.delete(io)
        io.close unless io.closed?
      end
    end

    # Sockets call this when their write buffer stops being empty. Wakes the
    # selector at most once per turn however many sockets have data.
    def writes_pending(io)
      wake { @pending_writes << io }
    end

    private

    def schedule(&task)
      wake { @todo << task }
    end

    def wake
      woken = @mutex.synchronize do
        yield
        @woken.tap { @woken = true }
      end
      @selector.wakeup unless woken
    end

    def run
      loop do
        todo, pending_writes = @mutex.synchronize do
          @woken = false
          [@todo.slice!(0..), @pending_writes.slice!(0..)]
        end
        todo.each(&:call)
        pending_writes.uniq.each { |io| flush(io) }

        @selector.select do |monitor|
          socket = monitor.value
          if monitor.writable? && socket.flush_write_buffer
            monitor.interests = :r
          end
          read(monitor.io, socket) if monitor.readable?
        rescue StandardError => e
          @logger&.debug("hocuspocus: socket error #{e.class}: #{e.message}")
          socket.io_closed
        end
      end
    end

    # Writes straight away; waits for writability only when the socket's
    # kernel buffer is full.
    def flush(io)
      monitor = @monitors[io] or return
      monitor.interests = :rw unless monitor.value.flush_write_buffer
    rescue StandardError
      monitor.value.io_closed
    end

    def read(io, socket)
      # One buffer serves every read: a fresh 16 KB string per read made
      # garbage collection the main cost under load. The parser keeps what
      # it is given, so it gets a copy of just the bytes read.
      case io.read_nonblock(READ_CHUNK, @read_buffer, exception: false)
      when :wait_readable, :wait_writable then nil
      when nil then socket.io_closed
      else socket.parse(@read_buffer.dup)
      end
    end
  end
end

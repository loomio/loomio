# frozen_string_literal: true

# Ported from @hocuspocus/server (https://github.com/ueberdosis/hocuspocus), MIT licence, copyright (c) 2023 Tiptap GmbH.
# See LICENSE-THIRD-PARTY.

module CollabServer
  # One collaborative document, held in memory while clients are connected.
  #
  # The document is a list of Yjs updates, compacted with Yjs.merge_updates.
  # Alongside it the document keeps the clock ranges of every struct and
  # deletion it has seen. Those ranges answer, without merging, whether an
  # incoming update adds anything; only updates that do are stored and
  # broadcast, as a Y.Doc emits nothing for content it already has.
  #
  # Sockets and pub/sub call in from several threads, so one mutex guards all
  # state. Broadcasts happen while holding it, so every connection sees updates
  # in the same order; Connection#send only enqueues.
  class Document
    # Updates are merged when a joining client needs a diff. Otherwise they
    # are merged only once they reach several times the merged state, which
    # bounds memory: merging costs time in proportion to the document, so
    # doing it while clients type delays everyone's edits.
    COMPACT_RATIO = 4
    COMPACT_BYTES_MIN = 256 * 1024

    attr_reader :name

    def initialize(name)
      @name = name
      @mutex = Mutex.new
      @updates = []
      @merged_bytes = 0
      @pending_bytes = 0
      @structs = {}
      @deletes = {}
      @connections = {}
      @awareness = Awareness.new
    end

    # Applies an update. Returns the part that was new to the document, after
    # broadcasting it, or nil when it added nothing.
    def apply_update(update)
      structs, deletes = Yjs.parse_update(update)
      @mutex.synchronize do
        next nil unless new_content?(structs, deletes)

        delta = starts_after_state?(structs) ? update : Yjs.diff_update(update, state_vector_unlocked)
        structs.each { |client, ranges| add_ranges(@structs, client, ranges) }
        deletes.each { |client, ranges| add_ranges(@deletes, client, ranges) }
        @updates << delta
        @pending_bytes += delta.bytesize
        compact_unlocked if @pending_bytes > (@merged_bytes * COMPACT_RATIO) + COMPACT_BYTES_MIN
        broadcast_unlocked(Protocol.sync(name, Protocol::SYNC_UPDATE, delta))
        delta
      end
    end

    def state_vector
      @mutex.synchronize { state_vector_unlocked }
    end

    def state
      @mutex.synchronize { compact_unlocked }
    end

    def diff(state_vector)
      @mutex.synchronize { Yjs.diff_update(compact_unlocked, state_vector) }
    end

    # Applies an awareness update from a local connection, or from another
    # server process when `connection` is nil. Returns the update to relay to
    # other processes, or nil when nothing changed.
    def apply_awareness(update, connection = nil)
      @mutex.synchronize do
        added, updated, removed = @awareness.apply(update)
        if connection && (clients = @connections[connection])
          clients.merge(added)
          clients.subtract(removed)
        end
        changed = added + updated + removed
        changed.empty? ? nil : broadcast_awareness_unlocked(changed)
      end
    end

    def awareness_update
      @mutex.synchronize { @awareness.states? ? @awareness.encode : nil }
    end

    # Clears states that were not renewed, as when a client vanishes without
    # closing its socket. Returns the removal to relay, or nil.
    def expire_awareness
      @mutex.synchronize do
        removed = @awareness.remove(@awareness.outdated_client_ids)
        removed.empty? ? nil : broadcast_awareness_unlocked(removed)
      end
    end

    # Attaches a connection and sends it the current awareness states.
    def add_connection(connection)
      @mutex.synchronize do
        @connections[connection] = Set.new
        connection.send(Protocol.awareness(name, @awareness.encode)) if @awareness.states?
      end
    end

    # Detaches a connection and clears its clients' awareness. Returns the
    # removal to relay, or nil.
    def remove_connection(connection)
      @mutex.synchronize do
        clients = @connections.delete(connection)
        next nil unless clients

        removed = @awareness.remove(clients.to_a)
        removed.empty? ? nil : broadcast_awareness_unlocked(removed)
      end
    end

    def connection?(connection)
      @mutex.synchronize { @connections.key?(connection) }
    end

    def idle?
      @mutex.synchronize { @connections.empty? }
    end

    private

    def new_content?(structs, deletes)
      structs.any? { |client, ranges| ranges.any? { |clock, length| !covered?(@structs, client, clock, length) } } ||
        deletes.any? { |client, ranges| ranges.any? { |clock, length| !covered?(@deletes, client, clock, length) } }
    end

    # True when every struct is past what the document holds contiguously,
    # so trimming the update with diff_update would leave it unchanged.
    def starts_after_state?(structs)
      structs.all? do |client, ranges|
        known = @structs[client]&.first
        known.nil? || !known[0].zero? || ranges.all? { |clock, _length| clock >= known[0] + known[1] }
      end
    end

    # Ranges are sorted and merged, so a covered span lies within the last
    # range that starts at or before it.
    def covered?(ranges_by_client, client, clock, length)
      ranges = ranges_by_client[client] or return false
      index = ranges.bsearch_index { |start, _length| start > clock }
      range = index.nil? ? ranges.last : (index.zero? ? nil : ranges[index - 1])
      range && range[0] + range[1] >= clock + length
    end

    def add_ranges(ranges_by_client, client, ranges)
      ranges_by_client[client] = Yjs::DeleteSet.sort_and_merge(ranges_by_client.fetch(client, []) + ranges)
    end

    # A client's state is the end of its structs that are contiguous from 0.
    def state_vector_unlocked
      clocks = @structs.filter_map do |client, ranges|
        first = ranges.first
        [client, first[0] + first[1]] if first[0].zero?
      end
      Yjs.encode_state_vector(clocks)
    end

    def compact_unlocked
      return @updates.first if @updates.length == 1

      merged = @updates.empty? ? Yjs::EMPTY_UPDATE : Yjs.merge_updates(@updates)
      @updates = [merged]
      @merged_bytes = merged.bytesize
      @pending_bytes = 0
      merged
    end

    def broadcast_awareness_unlocked(client_ids)
      update = @awareness.encode(client_ids)
      broadcast_unlocked(Protocol.awareness(name, update))
      update
    end

    def broadcast_unlocked(message)
      @connections.each_key { |connection| connection.send(message) }
    end
  end
end

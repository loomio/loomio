# frozen_string_literal: true

# Ported from y-protocols (https://github.com/yjs/y-protocols), MIT licence, copyright (c) 2019 Kevin Jahns.
# See LICENSE-THIRD-PARTY.

require "json"

module CollabServer
  # Server-side copy of y-protocols awareness: the latest presence state
  # (cursor, user name, ...) for each client of a document. States stay as the
  # JSON strings clients sent, since the server never reads them.
  #
  # Not thread-safe; Document serializes access.
  class Awareness
    OUTDATED_TIMEOUT = 30 # seconds, as in y-protocols

    Entry = Struct.new(:clock, :state, :updated_at)

    def initialize
      @entries = {}
    end

    def states?
      @entries.any? { |_client, entry| entry.state }
    end

    def client_ids
      @entries.select { |_client, entry| entry.state }.keys
    end

    # Applies an encoded awareness update, following y-protocols'
    # applyAwarenessUpdate. Returns the ids of clients that were added, updated
    # and removed.
    def apply(update, now: monotonic_now)
      decoder = Lib0::Decoder.new(update)
      # Each entry is at least a client id, a clock and a state.
      changes = Array.new(decoder.read_count(3)) do
        client = decoder.read_var_uint
        clock = decoder.read_var_uint
        json = decoder.read_var_string
        [client, clock, JSON.parse(json).nil? ? nil : json]
      end

      added = []
      updated = []
      removed = []
      changes.each do |client, clock, state|
        entry = @entries[client]
        current_clock = entry ? entry.clock : 0
        # A removal at the same clock still wins.
        next unless current_clock < clock || (current_clock == clock && state.nil? && entry&.state)

        @entries[client] = Entry.new(clock, state, now)
        if entry.nil?
          added << client if state
        elsif state.nil?
          removed << client
        else
          updated << client
        end
      end
      [added, updated, removed]
    rescue JSON::ParserError => e
      raise Lib0::DecodeError, "invalid awareness state: #{e.message}"
    end

    # Clears the states of the given clients when their connection closes or
    # goes quiet. The clock stays the same: peers accept a removal at the clock
    # they already have.
    def remove(client_ids, now: monotonic_now)
      client_ids.select do |client|
        entry = @entries[client]
        next false unless entry&.state

        @entries[client] = Entry.new(entry.clock, nil, now)
        true
      end
    end

    def outdated_client_ids(now: monotonic_now)
      @entries.select { |_client, entry| entry.state && now - entry.updated_at >= OUTDATED_TIMEOUT }.keys
    end

    def encode(client_ids = self.client_ids)
      encoder = Lib0::Encoder.new
      entries = client_ids.filter_map { |client| (entry = @entries[client]) && [client, entry] }
      encoder.write_var_uint(entries.length)
      entries.each do |client, entry|
        encoder.write_var_uint(client)
        encoder.write_var_uint(entry.clock)
        encoder.write_var_string(entry.state || "null")
      end
      encoder.to_s
    end

    private

    def monotonic_now
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end
end

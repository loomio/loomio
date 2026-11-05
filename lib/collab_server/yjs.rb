# frozen_string_literal: true

# Ported from yjs (https://github.com/yjs/yjs), MIT licence, copyright (c) 2023 Kevin Jahns and RWTH Aachen University.
# See LICENSE-THIRD-PARTY.

module CollabServer
  # Operations on encoded Yjs (v1) updates, ported from yjs/src/utils/updates.js.
  #
  # The server never integrates updates into a CRDT document. It only needs to
  # merge updates, compute the part of a document a client is missing, and
  # derive state vectors. Yjs provides those operations directly on the binary
  # update format, so the server can relay documents without a native Yjs
  # library. Content the server never splits is kept as raw bytes and written
  # back unchanged.
  module Yjs
    BIT6 = 0x20
    BIT7 = 0x40
    BIT8 = 0x80
    BITS5 = 0x1f
    GC_REF = 0
    SKIP_REF = 10

    ID = Data.define(:client, :clock)

    class Gc
      attr_reader :id
      attr_accessor :length

      def initialize(id, length)
        @id = id
        @length = length
      end

      def merge_with(right)
        return false unless right.instance_of?(self.class)

        @length += right.length
        true
      end

      def slice(diff)
        self.class.new(ID.new(id.client, id.clock + diff), length - diff)
      end

      def write(encoder, offset)
        encoder.write_uint8(GC_REF)
        encoder.write_var_uint(length - offset)
      end
    end

    class Skip < Gc
      def write(encoder, offset)
        encoder.write_uint8(SKIP_REF)
        encoder.write_var_uint(length - offset)
      end
    end

    class Item
      attr_reader :id, :origin, :right_origin, :parent, :parent_sub, :content

      def initialize(id, origin, right_origin, parent, parent_sub, content)
        @id = id
        @origin = origin
        @right_origin = right_origin
        @parent = parent
        @parent_sub = parent_sub
        @content = content
      end

      def length
        content.length
      end

      # Yjs merges items only once they are integrated into a document, so
      # items read from an update never merge (Item#mergeWith compares `right`
      # pointers, which are always null in a lazily read update).
      def merge_with(_right)
        false
      end

      def slice(diff)
        Item.new(
          ID.new(id.client, id.clock + diff),
          ID.new(id.client, id.clock + diff - 1),
          right_origin,
          parent,
          parent_sub,
          content.splice(diff)
        )
      end

      def write(encoder, offset)
        origin = offset.positive? ? ID.new(id.client, id.clock + offset - 1) : self.origin
        info = (content.ref & BITS5) |
          (origin.nil? ? 0 : BIT8) |
          (right_origin.nil? ? 0 : BIT7) |
          (parent_sub.nil? ? 0 : BIT6)
        encoder.write_uint8(info)
        write_id(encoder, origin) if origin
        write_id(encoder, right_origin) if right_origin
        if origin.nil? && right_origin.nil?
          case parent
          when String
            encoder.write_var_uint(1)
            encoder.write_var_string(parent)
          when ID
            encoder.write_var_uint(0)
            write_id(encoder, parent)
          else
            raise Lib0::DecodeError, "item without a parent"
          end
          encoder.write_var_string(parent_sub) if parent_sub
        end
        content.write(encoder, offset)
      end

      private

      def write_id(encoder, id)
        encoder.write_var_uint(id.client)
        encoder.write_var_uint(id.clock)
      end
    end

    class ContentDeleted
      attr_reader :length

      def initialize(length)
        @length = length
      end

      def ref = 1

      def splice(offset)
        right = ContentDeleted.new(@length - offset)
        @length = offset
        right
      end

      def write(encoder, offset)
        encoder.write_var_uint(@length - offset)
      end
    end

    # JSON (ref 2) and Any (ref 8) content: arrays whose elements are kept in
    # their encoded form.
    class ContentList
      attr_reader :ref, :elements

      def initialize(ref, elements)
        @ref = ref
        @elements = elements
      end

      def length
        elements.length
      end

      def splice(offset)
        right = ContentList.new(ref, elements[offset..])
        @elements = elements[0, offset]
        right
      end

      def write(encoder, offset)
        encoder.write_var_uint(elements.length - offset)
        elements.drop(offset).each do |element|
          ref == 2 ? encoder.write_var_string(element) : encoder.write_raw(element)
        end
      end
    end

    # Yjs measures strings in UTF-16 code units, so lengths and split offsets
    # count characters outside the Basic Multilingual Plane twice.
    class ContentString
      REPLACEMENT = "�"
      ASTRAL_LEAD_BYTES = "\xF0-\xF4".b.freeze # start characters that take two UTF-16 code units

      attr_reader :string, :length

      def initialize(string)
        @string = string
        # In valid UTF-8 (the decoder checks) each character outside the BMP
        # starts with a byte from F0 to F4; counting bytes is fast in C.
        @length = string.ascii_only? ? string.bytesize : string.length + string.b.count(ASTRAL_LEAD_BYTES)
      end

      def ref = 4

      def splice(offset)
        left, right = self.class.split(string, offset)
        @string = left
        @length = offset
        ContentString.new(right)
      end

      def write(encoder, offset)
        encoder.write_var_string(offset.zero? ? string : self.class.split(string, offset).last)
      end

      # Splits like JavaScript's String#slice at a UTF-16 offset. Splitting a
      # surrogate pair leaves a replacement character on each side, as Yjs does.
      def self.split(string, offset)
        units = 0
        left = +""
        chars = string.each_char.to_a
        chars.each_with_index do |char, index|
          return [left, chars[index..].join] if units == offset

          width = char.ord > 0xffff ? 2 : 1
          if units + width > offset
            return [left + REPLACEMENT, REPLACEMENT + chars[(index + 1)..].join]
          end

          left << char
          units += width
        end
        [left, +""]
      end
    end

    # Content the server never splits (binary, embed, format, type, subdoc):
    # each has length 1 and is copied through as raw bytes.
    class ContentOpaque
      attr_reader :ref, :bytes

      def initialize(ref, bytes)
        @ref = ref
        @bytes = bytes
      end

      def length = 1

      def splice(_offset)
        raise Lib0::DecodeError, "content of type #{ref} cannot be split"
      end

      def write(encoder, _offset)
        encoder.write_raw(bytes)
      end
    end

    # Reads the structs of an update one at a time (Yjs's LazyStructReader).
    class LazyStructReader
      attr_reader :curr

      def initialize(decoder, filter_skips)
        @decoder = decoder
        @filter_skips = filter_skips
        @clients_remaining = decoder.read_count(3)
        @structs_remaining = 0
        self.next
      end

      def next
        loop do
          @curr = read_struct
          break unless @filter_skips && @curr.instance_of?(Skip)
        end
        @curr
      end

      private

      def read_struct
        while @structs_remaining.zero?
          return nil if @clients_remaining.zero?

          @clients_remaining -= 1
          @structs_remaining = @decoder.read_count
          @client = @decoder.read_var_uint
          @clock = @decoder.read_var_uint
        end
        @structs_remaining -= 1

        id = ID.new(@client, @clock)
        info = @decoder.read_uint8
        struct =
          if info == SKIP_REF
            Skip.new(id, @decoder.read_var_uint)
          elsif (info & BITS5).zero?
            Gc.new(id, @decoder.read_var_uint)
          else
            read_item(id, info)
          end
        raise Lib0::DecodeError, "struct has no length" unless struct.length.positive?

        @clock += struct.length
        struct
      end

      def read_item(id, info)
        cant_copy_parent_info = (info & (BIT7 | BIT8)).zero?
        origin = (info & BIT8) == BIT8 ? read_id : nil
        right_origin = (info & BIT7) == BIT7 ? read_id : nil
        parent = nil
        parent_sub = nil
        if cant_copy_parent_info
          parent = @decoder.read_var_uint == 1 ? @decoder.read_var_string : read_id
          parent_sub = @decoder.read_var_string if (info & BIT6) == BIT6
        end
        Item.new(id, origin, right_origin, parent, parent_sub, read_content(info & BITS5))
      end

      def read_id
        ID.new(@decoder.read_var_uint, @decoder.read_var_uint)
      end

      def read_content(ref)
        case ref
        when 1 then ContentDeleted.new(@decoder.read_var_uint)
        when 2 then ContentList.new(2, Array.new(@decoder.read_count) { @decoder.read_var_string })
        when 4 then ContentString.new(@decoder.read_var_string)
        when 8 then ContentList.new(8, Array.new(@decoder.read_count) { @decoder.read_any_raw })
        when 3, 5, 6, 7, 9 then ContentOpaque.new(ref, read_opaque_bytes(ref))
        else raise Lib0::DecodeError, "unknown content type #{ref}"
        end
      end

      def read_opaque_bytes(ref)
        start = @decoder.pos
        case ref
        when 3 then @decoder.read_var_uint8_array # binary
        when 5 then @decoder.read_var_string # embed (JSON)
        when 6 # format: key, then JSON value
          @decoder.read_var_string
          @decoder.read_var_string
        when 7 # type: type ref, plus a node name for XML elements and hooks
          type_ref = @decoder.read_var_uint
          raise Lib0::DecodeError, "unknown type ref #{type_ref}" if type_ref > 6

          @decoder.read_var_string if type_ref == 3 || type_ref == 5
        when 9 # subdocument: guid, then options
          @decoder.read_var_string
          @decoder.read_any_raw
        end
        length = @decoder.pos - start
        @decoder.pos = start
        @decoder.read_bytes(length)
      end
    end

    # Writes structs while counting them per client (Yjs's LazyStructWriter):
    # the update format needs each client's struct count before its structs.
    class LazyStructWriter
      def initialize
        @client_structs = []
        @encoder = Lib0::Encoder.new
        @written = 0
        @client = nil
      end

      def write(struct, offset)
        flush if @written.positive? && @client != struct.id.client
        if @written.zero?
          @client = struct.id.client
          @encoder.write_var_uint(struct.id.client)
          @encoder.write_var_uint(struct.id.clock + offset)
        end
        struct.write(@encoder, offset)
        @written += 1
      end

      # Returns an encoder holding the struct section, ready for a delete set.
      def finish
        flush
        encoder = Lib0::Encoder.new
        encoder.write_var_uint(@client_structs.length)
        @client_structs.each do |written, bytes|
          encoder.write_var_uint(written)
          encoder.write_raw(bytes)
        end
        encoder
      end

      private

      def flush
        return unless @written.positive?

        @client_structs << [@written, @encoder.to_s]
        @encoder = Lib0::Encoder.new
        @written = 0
      end
    end

    # Deleted ranges per client: { client => [[clock, length], ...] }.
    module DeleteSet
      module_function

      def read(decoder)
        clients = {}
        decoder.read_count(2).times do
          client = decoder.read_var_uint
          count = decoder.read_count(2)
          next if count.zero?

          ranges = (clients[client] ||= [])
          count.times { ranges << [decoder.read_var_uint, decoder.read_var_uint] }
        end
        clients
      end

      def merge(delete_sets)
        merged = {}
        delete_sets.each do |delete_set|
          delete_set.each { |client, ranges| (merged[client] ||= []).concat(ranges) }
        end
        merged.transform_values { |ranges| sort_and_merge(ranges) }
      end

      def sort_and_merge(ranges)
        ranges.each_with_index.sort_by { |(clock, _length), index| [clock, index] }.each_with_object([]) do |((clock, length), _index), result|
          last = result.last
          if last && last[0] + last[1] >= clock
            result[-1] = [last[0], [last[1], clock + length - last[0]].max]
          else
            result << [clock, length]
          end
        end
      end

      def write(encoder, delete_set)
        encoder.write_var_uint(delete_set.size)
        delete_set.sort_by { |client, _ranges| -client }.each do |client, ranges|
          encoder.write_var_uint(client)
          encoder.write_var_uint(ranges.length)
          ranges.each do |clock, length|
            encoder.write_var_uint(clock)
            encoder.write_var_uint(length)
          end
        end
      end
    end

    EMPTY_UPDATE = "\x00\x00".b.freeze

    module_function

    # Y.mergeUpdates. The algorithm is ported statement by statement so the
    # result is byte-identical to Yjs's output for the same inputs.
    def merge_updates(updates)
      return updates.first if updates.length == 1

      decoders = updates.map { |update| Lib0::Decoder.new(update) }
      readers = decoders.map { |decoder| LazyStructReader.new(decoder, true) }
      writer = LazyStructWriter.new
      current = nil

      loop do
        readers = sort_readers(readers.select(&:curr))
        break if readers.empty?

        reader = readers.first
        first_client = reader.curr.id.client

        if current
          curr = reader.curr
          iterated = false
          # Skip structs that have already been written; higher clients come first.
          while curr && curr.id.clock + curr.length <= current.id.clock + current.length && curr.id.client >= current.id.client
            curr = reader.next
            iterated = true
          end
          next if curr.nil? ||
            curr.id.client != first_client ||
            (iterated && curr.id.clock > current.id.clock + current.length)

          if first_client != current.id.client
            writer.write(current, 0)
            current = curr
            reader.next
          elsif current.id.clock + current.length < curr.id.clock
            # A gap in this client's clocks: fill it with a Skip.
            if current.instance_of?(Skip)
              current.length = curr.id.clock + curr.length - current.id.clock
            else
              writer.write(current, 0)
              gap = curr.id.clock - current.id.clock - current.length
              current = Skip.new(ID.new(first_client, current.id.clock + current.length), gap)
            end
          else
            overlap = current.id.clock + current.length - curr.id.clock
            if overlap.positive?
              if current.instance_of?(Skip)
                current.length -= overlap
              else
                curr = curr.slice(overlap)
              end
            end
            unless current.merge_with(curr)
              writer.write(current, 0)
              current = curr
              reader.next
            end
          end
        else
          current = reader.curr
          reader.next
        end

        following = reader.curr
        while following && following.id.client == first_client &&
            following.id.clock == current.id.clock + current.length && !following.instance_of?(Skip)
          writer.write(current, 0)
          current = following
          following = reader.next
        end
      end
      writer.write(current, 0) if current

      encoder = writer.finish
      DeleteSet.write(encoder, DeleteSet.merge(decoders.map { |decoder| DeleteSet.read(decoder) }))
      encoder.to_s
    end

    # Y.diffUpdate: the part of `update` that a peer with `state_vector` lacks.
    def diff_update(update, state_vector)
      state = decode_state_vector(state_vector)
      writer = LazyStructWriter.new
      decoder = Lib0::Decoder.new(update)
      reader = LazyStructReader.new(decoder, false)
      while (curr = reader.curr)
        client = curr.id.client
        known_clock = state.fetch(client, 0)
        if curr.instance_of?(Skip)
          reader.next
        elsif curr.id.clock + curr.length > known_clock
          writer.write(curr, [known_clock - curr.id.clock, 0].max)
          reader.next
          while reader.curr && reader.curr.id.client == client
            writer.write(reader.curr, 0)
            reader.next
          end
        else
          reader.next while reader.curr && reader.curr.id.client == client && reader.curr.id.clock + reader.curr.length <= known_clock
        end
      end
      encoder = writer.finish
      DeleteSet.write(encoder, DeleteSet.read(decoder))
      encoder.to_s
    end

    # Y.encodeStateVectorFromUpdate.
    def encode_state_vector_from_update(update)
      reader = LazyStructReader.new(Lib0::Decoder.new(update), false)
      clocks = []
      curr = reader.curr
      if curr
        client = curr.id.client
        stop_counting = curr.id.clock != 0
        clock = stop_counting ? 0 : curr.id.clock + curr.length
        while curr
          if client != curr.id.client
            clocks << [client, clock] unless clock.zero?
            client = curr.id.client
            clock = 0
            stop_counting = curr.id.clock != 0
          end
          stop_counting = true if curr.instance_of?(Skip)
          clock = curr.id.clock + curr.length unless stop_counting
          curr = reader.next
        end
        clocks << [client, clock] unless clock.zero?
      end
      encode_state_vector(clocks, sort: false)
    end

    def encode_state_vector(clocks, sort: true)
      clocks = clocks.sort_by { |client, _clock| -client } if sort
      encoder = Lib0::Encoder.new
      encoder.write_var_uint(clocks.length)
      clocks.each do |client, clock|
        encoder.write_var_uint(client)
        encoder.write_var_uint(clock)
      end
      encoder.to_s
    end

    def decode_state_vector(state_vector)
      decoder = Lib0::Decoder.new(state_vector)
      Array.new(decoder.read_count(2)) { [decoder.read_var_uint, decoder.read_var_uint] }.to_h
    end

    # Decodes a whole update, rejecting malformed input. Returns the clock
    # ranges of its structs (Skips excluded) and its delete set.
    def parse_update(update)
      decoder = Lib0::Decoder.new(update)
      reader = LazyStructReader.new(decoder, true)
      structs = {}
      while (curr = reader.curr)
        (structs[curr.id.client] ||= []) << [curr.id.clock, curr.length]
        reader.next
      end
      [structs, DeleteSet.read(decoder)]
    end

    # Yjs sorts with a stable sort: higher clients first, then lower clocks.
    def sort_readers(readers)
      readers.each_with_index.sort do |(left, left_index), (right, right_index)|
        a = left.curr
        b = right.curr
        order =
          if a.id.client == b.id.client
            clock_order = a.id.clock <=> b.id.clock
            if clock_order.zero? && !a.instance_of?(b.class)
              a.instance_of?(Skip) ? 1 : -1
            else
              clock_order
            end
          else
            b.id.client <=> a.id.client
          end
        order.zero? ? left_index <=> right_index : order
      end.map(&:first)
    end
  end
end

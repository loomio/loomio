# frozen_string_literal: true

# Ported from lib0 (https://github.com/dmonad/lib0), MIT licence, copyright (c) 2019 Kevin Jahns.
# See LICENSE-THIRD-PARTY.

module Hocuspocus
  # Binary encoding used by Yjs and y-protocols (a port of the parts of lib0's
  # encoding/decoding modules that the sync, awareness and auth protocols use).
  module Lib0
    class DecodeError < StandardError; end

    class Encoder
      def initialize
        @buffer = String.new(encoding: Encoding::BINARY)
      end

      def write_uint8(value)
        @buffer << (value & 0xff)
        self
      end

      def write_var_uint(value)
        raise ArgumentError, "var uint must be non-negative" if value.negative?

        while value > 0x7f
          @buffer << (0x80 | (value & 0x7f))
          value >>= 7
        end
        @buffer << value
        self
      end

      # Strings from decoded messages are already valid UTF-8 and are copied
      # as they are; transcoding them made large documents slow to send.
      def write_var_string(string)
        string = string.to_s
        unless string.encoding == Encoding::UTF_8 && string.valid_encoding?
          string = string.encode(Encoding::UTF_8, invalid: :replace, undef: :replace)
        end
        write_var_uint(string.bytesize)
        @buffer.append_as_bytes(string)
        self
      end

      def write_var_uint8_array(bytes)
        write_var_uint(bytes.bytesize)
        @buffer.append_as_bytes(bytes)
        self
      end

      # Appends bytes without a length prefix.
      def write_raw(bytes)
        @buffer.append_as_bytes(bytes)
        self
      end

      def length
        @buffer.bytesize
      end

      # Returns the buffer itself; encoders are not written to afterwards.
      def to_s
        @buffer
      end
    end

    class Decoder
      attr_accessor :pos

      def initialize(bytes)
        @bytes = bytes.encoding == Encoding::BINARY ? bytes : bytes.b
        @pos = 0
      end

      def content?
        @pos < @bytes.bytesize
      end

      def read_uint8
        raise DecodeError, "unexpected end of array" unless content?

        byte = @bytes.getbyte(@pos)
        @pos += 1
        byte
      end

      def read_var_uint
        value = 0
        shift = 0
        loop do
          byte = read_uint8
          value |= (byte & 0x7f) << shift
          return value if byte < 0x80

          shift += 7
          # lib0 limits var uints to 53 bits (JavaScript's safe integer range).
          raise DecodeError, "integer out of range" if shift > 53
        end
      end

      # Reads the number of entries that follow. Each entry takes at least
      # `bytes_min` bytes, so a count the rest of the message cannot hold is
      # rejected before anything is allocated for it.
      def read_count(bytes_min = 1)
        count = read_var_uint
        raise DecodeError, "count exceeds message length" if count * bytes_min > @bytes.bytesize - @pos

        count
      end

      def read_bytes(length)
        raise DecodeError, "unexpected end of array" if @pos + length > @bytes.bytesize

        slice = @bytes.byteslice(@pos, length)
        @pos += length
        slice
      end

      def read_var_uint8_array
        read_bytes(read_var_uint)
      end

      def read_var_string
        string = read_var_uint8_array.force_encoding(Encoding::UTF_8)
        raise DecodeError, "invalid UTF-8 string" unless string.valid_encoding?

        string
      end

      def skip_var_int
        loop { break if read_uint8 < 0x80 }
      end

      # Skips one lib0 "any" value and returns its raw encoding, so content can
      # be re-emitted byte-for-byte without a lossy decode/encode round trip.
      def read_any_raw
        start = @pos
        skip_any
        @bytes.byteslice(start, @pos - start)
      end

      def remaining
        @bytes.byteslice(@pos, @bytes.bytesize - @pos)
      end

      private

      def skip_any(depth = 0)
        raise DecodeError, "value nested too deeply" if depth > 100

        case read_uint8
        when 127, 126, 121, 120 then nil # undefined, null, false, true
        when 125 then skip_var_int # integer
        when 124 then read_bytes(4) # float32
        when 123, 122 then read_bytes(8) # float64, bigint64
        when 119 then read_var_string
        when 118
          read_count(2).times do
            read_var_string
            skip_any(depth + 1)
          end
        when 117 then read_count.times { skip_any(depth + 1) }
        when 116 then read_var_uint8_array
        else raise DecodeError, "unknown any type"
        end
      end
    end
  end
end

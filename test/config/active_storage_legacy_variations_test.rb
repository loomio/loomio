require "test_helper"

class ActiveStorageLegacyVariationsTest < ActiveSupport::TestCase
  test "returns an unprocessable response when a corrupt file cannot be previewed" do
    base_controller = Class.new do
      attr_reader :response_status

      def set_representation
        raise ActiveStorage::PreviewError, "document stream is empty"
      end

      def params
        { signed_blob_id: "test-blob" }
      end

      def head(status)
        @response_status = status
      end
    end
    controller_class = Class.new(base_controller)
    controller_class.prepend(ActiveStorageRepresentationLegacyRescue)
    controller = controller_class.new

    controller.send(:set_representation)

    assert_equal :unprocessable_entity, controller.response_status
  end

  test "translates legacy variations when Hot Cell wraps a worker TypeError as ConversionTemporarilyUnavailable" do
    variation_key = ActiveStorage::Variation.encode(resize: "200x200>")
    translated_args = nil
    fake_blob = Object.new
    fake_blob.define_singleton_method(:representation) do |args|
      translated_args = args
      Struct.new(:processed).new(:translated_representation)
    end

    base_controller = Class.new do
      attr_reader :representation

      def initialize(blob, key)
        @blob = blob
        @key = key
      end

      def set_representation
        raise LoomioHotCell::ConversionTemporarilyUnavailable, "failed: TypeError: no implicit conversion to float from string"
      end

      def params
        { signed_blob_id: "test-blob", variation_key: @key }
      end
    end

    controller_class = Class.new(base_controller)
    controller_class.prepend(ActiveStorageRepresentationLegacyRescue)
    controller = controller_class.new(fake_blob, variation_key)

    controller.send(:set_representation)

    assert_equal({ resize_to_limit: [ 200, 200 ] }, translated_args)
    assert_equal :translated_representation, controller.representation
  end
end

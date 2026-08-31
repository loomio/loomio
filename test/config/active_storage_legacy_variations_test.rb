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
end

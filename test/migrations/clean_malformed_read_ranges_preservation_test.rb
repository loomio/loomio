require "test_helper"
require Rails.root.join("db/migrate/20260501000001_clean_malformed_topic_reader_read_ranges")

class CleanMalformedReadRangesPreservationTest < ActiveSupport::TestCase
  test "malformed read history is reset without changing direct-topic access or preferences" do
    reader = TopicReader.find_by!(topic: topics(:direct_topic), user: users(:guest_loud))
    reader.update_column(:read_ranges_string, "bad-range")
    original = reader.attributes.except("read_ranges_string")

    2.times { CleanMalformedTopicReaderReadRanges.new.migrate(:up) }

    assert_equal "", reader.reload.read_ranges_string
    assert_equal original, reader.attributes.except("read_ranges_string")
    assert users(:guest_loud).ability.can?(:show, topics(:direct_topic).topicable)
  end
end

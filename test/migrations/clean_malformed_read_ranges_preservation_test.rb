require "test_helper"
require_relative "../support/access_volume_matrix"
require Rails.root.join("db/migrate/20260501000001_clean_malformed_topic_reader_read_ranges")

class CleanMalformedReadRangesPreservationTest < ActiveSupport::TestCase
  include AccessVolumeMatrix

  test "repair preserves access and channel preferences across the group and direct-topic matrices" do
    readers = TopicReader.where(topic: topics(:discussion_topic, :direct_topic))
    readers.update_all(read_ranges_string: "bad-range")
    original = readers.order(:id).map { |reader| reader.attributes.except("read_ranges_string") }
    unrelated = TopicReader.where.not(id: readers.select(:id)).order(:id).map(&:attributes)
    before = access_volume_matrix

    2.times { CleanMalformedTopicReaderReadRanges.new.migrate(:up) }

    assert_equal [ "" ], readers.distinct.pluck(:read_ranges_string)
    assert_equal original, readers.reload.order(:id).map { |reader| reader.attributes.except("read_ranges_string") }
    assert_equal unrelated, TopicReader.where.not(id: readers.select(:id)).order(:id).map(&:attributes)
    assert_access_volume_matrix_unchanged(before)
  end
end

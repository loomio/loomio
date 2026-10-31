require 'test_helper'

class HasPollSequenceTest < ActiveSupport::TestCase
  test 'new topics and discussion templates default to unrestricted polls' do
    [Topic, DiscussionTemplate].each do |model|
      assert_equal false, model.new.polls_one_at_a_time
      assert_equal false, model.new[:polls_one_at_a_time]
    end
  end

  test 'legacy settings remain effective until conversion and explicit edits keep rollback values consistent' do
    [topics(:discussion_topic), discussion_templates(:cleanup_discussion_template)].each do |record|
      [false, true].each do |legacy_value|
        record.update_columns(allow_concurrent_polls: legacy_value, polls_one_at_a_time: nil)
        record.reload
        assert_equal !legacy_value, record.polls_one_at_a_time
        assert_equal !legacy_value, record.polls_one_at_a_time?

        record.update!(polls_one_at_a_time: legacy_value)
        assert_equal legacy_value, record.reload[:polls_one_at_a_time]
        assert_equal !legacy_value, record[:allow_concurrent_polls]
      end
    end
  end

  test 'copying legacy attributes preserves the choice before conversion' do
    [Topic, DiscussionTemplate].each do |model|
      [false, true].each do |legacy_value|
        copy = model.new(allow_concurrent_polls: legacy_value, polls_one_at_a_time: nil)
        assert_equal !legacy_value, copy.polls_one_at_a_time
        assert_equal legacy_value, copy[:allow_concurrent_polls]
      end
    end
  end

  test 'API serializers expose the effective setting before conversion' do
    [[topics(:discussion_topic), TopicSerializer, :topic],
     [discussion_templates(:cleanup_discussion_template), DiscussionTemplateSerializer, :discussion_template]].each do |record, serializer, root|
      [false, true].each do |legacy_value|
        record.update_columns(allow_concurrent_polls: legacy_value, polls_one_at_a_time: nil)
        payload = serializer.new(record.reload).as_json.fetch(root)
        assert_equal !legacy_value, payload.fetch(:polls_one_at_a_time)
      end
    end
  end
end

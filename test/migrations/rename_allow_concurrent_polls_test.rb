require 'test_helper'
require_relative '../../db/migrate/20261031000002_rename_allow_concurrent_polls'

class RenameAllowConcurrentPollsTest < ActiveSupport::TestCase
  setup do
    discussion_templates(:cleanup_discussion_template).dup.save!
  end

  test 'renaming inverts both legacy choices and keeps new records unrestricted' do
    migration = RenameAllowConcurrentPolls.new
    migration.down

    [Topic, DiscussionTemplate].each do |model|
      ids = model.order(:id).limit(2).ids
      assert_equal 2, ids.length
      ids.zip([false, true]).each do |id, value|
        model.connection.execute("UPDATE #{model.table_name} SET allow_concurrent_polls = #{value} WHERE id = #{id}")
      end
    end

    assert_no_enqueued_jobs { migration.up }
    [Topic, DiscussionTemplate].each(&:reset_column_information)

    [Topic, DiscussionTemplate].each do |model|
      assert_equal [true, false], model.order(:id).limit(2).pluck(:polls_one_at_a_time)
      assert_not model.new.polls_one_at_a_time?
      assert_not model.column_names.include?('allow_concurrent_polls')
      assert_not model.columns_hash.fetch('polls_one_at_a_time').null
    end
  ensure
    [Topic, DiscussionTemplate].each(&:reset_column_information)
  end

  test 'rollback restores the original setting and default for both tables' do
    [Topic, DiscussionTemplate].each do |model|
      model.order(:id).limit(2).zip([false, true]).each do |record, value|
        record.update_columns(polls_one_at_a_time: value)
      end
    end

    migration = RenameAllowConcurrentPolls.new
    migration.down
    [Topic, DiscussionTemplate].each(&:reset_column_information)

    [Topic, DiscussionTemplate].each do |model|
      assert_equal [true, false], model.order(:id).limit(2).pluck(:allow_concurrent_polls)
      assert_not model.new.allow_concurrent_polls?
      assert_not model.column_names.include?('polls_one_at_a_time')
      assert_not model.columns_hash.fetch('allow_concurrent_polls').null
    end

    migration.up
    [Topic, DiscussionTemplate].each(&:reset_column_information)
    [Topic, DiscussionTemplate].each do |model|
      assert_equal [false, true], model.order(:id).limit(2).pluck(:polls_one_at_a_time)
    end
  ensure
    [Topic, DiscussionTemplate].each(&:reset_column_information)
  end
end

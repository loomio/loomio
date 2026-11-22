require "test_helper"

class DestroyTopicWorkerTest < ActiveSupport::TestCase
  setup do
    @thread_days_before = ENV["LOOMIO_DELETE_DISCARDED_THREADS_AFTER_X_DAYS"]
    ENV["LOOMIO_DELETE_DISCARDED_THREADS_AFTER_X_DAYS"] = "30"
  end

  teardown do
    ENV["LOOMIO_DELETE_DISCARDED_THREADS_AFTER_X_DAYS"] = @thread_days_before
  end

  test "deletes a discarded thread and its versions and search documents without dangling references" do
    discussion = discussions(:discussion)
    topic = discussion.topic
    comment = Comment.create!(parent: discussion, user: users(:member_normal), body: "Archived thread reply")
    comment.create_missing_created_topic_item!
    topic.versions.create!(event: "update")
    discussion.versions.create!(event: "update")
    comment.versions.create!(event: "update")
    discussion.pg_search_documents.create!(content: "Archived thread")
    comment.pg_search_documents.create!(content: "Archived reply")

    topic.update_column(:discarded_at, 31.days.ago)
    discarded_at = topic.discarded_at.iso8601(6)
    before = IntegrityAuditService.audit_orphan_records(include_ids: true)

    2.times { DestroyTopicWorker.perform_now(topic.id, discarded_at) }

    assert_not Topic.exists?(topic.id)
    assert_not Discussion.exists?(discussion.id)
    assert_not Comment.exists?(comment.id)
    [ topic, discussion, comment ].each { |record| assert_not PaperTrail::Version.exists?(item: record) }
    [ discussion, comment ].each { |record| assert_not PgSearch::Document.exists?(searchable: record) }

    after = IntegrityAuditService.audit_orphan_records(include_ids: true)
    after.slice(:dangling_records, :missing_polymorphic_targets).each do |category, scopes|
      scopes.each do |name, ids|
        assert_empty(ids - before.fetch(category).fetch(name, []), name)
      end
    end
  end

  test "preserves a discarded thread when disabled, restored, or inside a discarded group" do
    topic = discussions(:discussion).topic
    topic.update_column(:discarded_at, 31.days.ago)
    discarded_at = topic.discarded_at.iso8601(6)

    ENV.delete("LOOMIO_DELETE_DISCARDED_THREADS_AFTER_X_DAYS")
    DestroyTopicWorker.perform_now(topic.id, discarded_at)
    assert Topic.exists?(topic.id)

    ENV["LOOMIO_DELETE_DISCARDED_THREADS_AFTER_X_DAYS"] = "30"
    topic.group.update_column(:discarded_at, 1.day.ago)
    DestroyTopicWorker.perform_now(topic.id, discarded_at)
    assert Topic.exists?(topic.id)

    topic.group.update_column(:discarded_at, nil)
    topic.update_column(:discarded_at, 32.days.ago)
    DestroyTopicWorker.perform_now(topic.id, discarded_at)
    assert Topic.exists?(topic.id)
  end
end

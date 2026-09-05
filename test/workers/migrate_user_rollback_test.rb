require "test_helper"

class MigrateUserRollbackTest < ActiveSupport::TestCase
  test "merging an account into itself cannot delete its access or credentials" do
    user = users(:member_loud)
    original = user.attributes
    memberships = user.all_memberships.order(:id).map(&:attributes)
    readers = user.topic_readers.order(:id).map(&:attributes)
    token = LoginToken.create!(user: user)

    assert_no_enqueued_jobs do
      assert_raises(ArgumentError) { MigrateUserWorker.new.perform(user.id, user.id.to_s) }
    end

    assert_equal original, user.reload.attributes
    assert_equal memberships, user.all_memberships.reload.order(:id).map(&:attributes)
    assert_equal readers, user.topic_readers.reload.order(:id).map(&:attributes)
    assert_equal user.id, token.reload.user_id
  end

  test "failed duplicate cleanup restores membership and direct-topic role matrices" do
    [ [ users(:member_loud), users(:member_quiet) ], [ users(:guest_loud), users(:guest_normal) ] ].each do |source, destination|
      memberships = source.all_memberships.order(:id).map(&:attributes)
      readers = source.topic_readers.order(:id).map(&:attributes)
      worker = MigrateUserWorker.new
      worker.stub(:operations, -> { raise "failure after duplicate cleanup" }) do
        assert_raises(RuntimeError) { worker.perform(source.id, destination.id) }
      end

      assert_equal memberships, source.all_memberships.reload.order(:id).map(&:attributes)
      assert_equal readers, source.topic_readers.reload.order(:id).map(&:attributes)
      assert source.reload.email
    end
  end

  test "failure after redaction restores credentials and does not publish redaction side effects" do
    source = users(:guest_loud)
    destination = users(:guest_normal)
    source_before = source.attributes
    session = source.sessions.create!(user_agent: "Source browser", ip_address: "127.0.0.1")
    token = LoginToken.create!(user: source)
    redact = RedactUserWorker.method(:perform_now)

    NewsletterService.stub(:unsubscribe, ->(*) { flunk "rolled-back merge must not unsubscribe" }) do
      RedactUserWorker.stub(:perform_now, ->(*args) { redact.call(*args); raise "failure after redaction" }) do
        assert_no_enqueued_jobs(only: ActiveStorage::PurgeJob) do
          assert_raises(RuntimeError) { MigrateUserWorker.new.perform(source.id, destination.id) }
        end
      end
    end

    assert_equal source_before, source.reload.attributes
    assert Session.exists?(session.id)
    assert_equal source.id, token.reload.user_id
    assert source.ability.can?(:show, topics(:direct_topic).topicable)
  end
end

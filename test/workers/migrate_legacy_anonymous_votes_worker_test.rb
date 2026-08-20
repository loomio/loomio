require "test_helper"

class MigrateLegacyAnonymousVotesWorkerTest < ActiveSupport::TestCase
  test "limits concurrent jobs to one per topic" do
    assert_equal 1, MigrateLegacyAnonymousVotesWorker.concurrency_limit
    assert_equal 1.hour, MigrateLegacyAnonymousVotesWorker.concurrency_duration
    assert_equal 123, MigrateLegacyAnonymousVotesWorker.concurrency_key.call(123)
  end

  test "migrates every eligible poll in the topic" do
    first_poll = Struct.new(:id).new(1)
    second_poll = Struct.new(:id).new(2)
    relation = TopicPollRelation.new([ first_poll, second_poll ])
    migrated_polls = []

    LegacyAnonymousVoteMigrationService.stub(:eligible_poll_scope, relation) do
      LegacyAnonymousVoteMigrationService.stub(:migrate!, ->(poll:) { migrated_polls << poll }) do
        MigrateLegacyAnonymousVotesWorker.perform_now(123)
      end
    end

    assert_equal [ first_poll, second_poll ], migrated_polls
    assert_equal 123, relation.topic_id
  end

  test "continues after expected poll failures and raises a summary" do
    first_poll = Struct.new(:id).new(1)
    second_poll = Struct.new(:id).new(2)
    relation = TopicPollRelation.new([ first_poll, second_poll ])
    migrated_polls = []

    error = assert_raises(LegacyAnonymousVoteMigrationService::MigrationError) do
      LegacyAnonymousVoteMigrationService.stub(:eligible_poll_scope, relation) do
        LegacyAnonymousVoteMigrationService.stub(:migrate!, lambda { |poll:|
          migrated_polls << poll
          raise LegacyAnonymousVoteMigrationService::MigrationError, "invalid result" if poll == first_poll
        }) do
          MigrateLegacyAnonymousVotesWorker.perform_now(123)
        end
      end
    end

    assert_equal [ first_poll, second_poll ], migrated_polls
    assert_equal "Poll 1: invalid result", error.message
  end

  class TopicPollRelation
    attr_reader :topic_id

    def initialize(polls)
      @polls = polls
    end

    def where(topic_id:)
      @topic_id = topic_id
      self
    end

    def find_each(&block)
      @polls.each(&block)
    end
  end
end

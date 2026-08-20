require "test_helper"
require Rails.root.join("db/migrate/20260819000000_enqueue_legacy_anonymous_vote_migrations")

class EnqueueLegacyAnonymousVoteMigrationsTest < ActiveSupport::TestCase
  test "cleans closed polls sequentially before enqueuing one delayed job per topic" do
    first_poll = Struct.new(:id).new(1)
    second_poll = Struct.new(:id).new(2)
    cleanup_relation = CleanupPollRelation.new([ first_poll, second_poll ])
    relation = TopicRelation.new([ 12, 34, 56 ])
    operations = []

    assert_enqueued_jobs 3, only: MigrateLegacyAnonymousVotesWorker do
      LegacyAnonymousVoteMigrationService.stub(:eligible_poll_scope, cleanup_relation) do
        LegacyAnonymousVoteMigrationCleanupService.stub(:remove_cross_poll_stance_choices!, ->(poll:) { operations << poll.id }) do
          Poll.stub(:where, relation) do
            EnqueueLegacyAnonymousVoteMigrations.new.up
          end
        end
      end
    end

    assert_equal [ 1, 2 ], operations
    jobs = enqueued_jobs.select { |job| job.fetch(:job) == MigrateLegacyAnonymousVotesWorker }
    assert_equal [ [ 12 ], [ 34 ], [ 56 ] ], jobs.last(3).pluck(:args)
    assert jobs.last(3).all? { |job| job.fetch(:at) >= 14.minutes.from_now.to_f }
  end

  test "does not enqueue conversion jobs when cleanup fails" do
    poll = Struct.new(:id).new(1)
    cleanup_relation = CleanupPollRelation.new([ poll ])
    error = LegacyAnonymousVoteMigrationCleanupService::CleanupError.new("invalid stance")

    assert_no_enqueued_jobs only: MigrateLegacyAnonymousVotesWorker do
      assert_raises(LegacyAnonymousVoteMigrationCleanupService::CleanupError) do
        LegacyAnonymousVoteMigrationService.stub(:eligible_poll_scope, cleanup_relation) do
          LegacyAnonymousVoteMigrationCleanupService.stub(:remove_cross_poll_stance_choices!, ->(poll:) { raise error }) do
            EnqueueLegacyAnonymousVoteMigrations.new.up
          end
        end
      end
    end
  end

  test "uses Solid Queue for delayed jobs when the application adapter is inline" do
    queue_adapter = MigrateLegacyAnonymousVotesWorker.queue_adapter
    MigrateLegacyAnonymousVotesWorker.queue_adapter = :inline

    assert_difference -> { SolidQueue::Job.where(class_name: "MigrateLegacyAnonymousVotesWorker").count }, 1 do
      LegacyAnonymousVoteMigrationService.stub(:eligible_poll_scope, CleanupPollRelation.new([])) do
        Poll.stub(:where, TopicRelation.new([ 12 ])) do
          EnqueueLegacyAnonymousVoteMigrations.new.up
        end
      end
    end

    assert_instance_of ActiveJob::QueueAdapters::InlineAdapter,
                       MigrateLegacyAnonymousVotesWorker.queue_adapter
  ensure
    MigrateLegacyAnonymousVotesWorker.queue_adapter = queue_adapter if queue_adapter
  end

  class CleanupPollRelation
    def initialize(polls)
      @polls = polls
    end

    def find_each(order:, &block)
      raise "Expected ascending order" unless order == :asc

      @polls.each(&block)
    end
  end

  class TopicRelation
    def initialize(topic_ids)
      @topic_ids = topic_ids
    end

    def distinct
      self
    end

    def pluck(attribute)
      raise "Expected topic_id" unless attribute == :topic_id

      @topic_ids
    end
  end
end

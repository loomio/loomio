class LegacyAnonymousVoteMigrationCleanupService
  class CleanupError < LegacyAnonymousVoteMigrationService::MigrationError; end

  def self.cleanup!(poll:)
    Poll.transaction(requires_new: true) do
      poll.lock!
      validate_poll!(poll)

      removed_stances = remove_invalid_stances!(poll: poll)

      mismatches = detached_ballot_choice_mismatches(poll.id)
      unless mismatches.empty?
        raise CleanupError, "Poll #{poll.id} has detached ballot choices for another poll: #{format_mismatches(mismatches)}"
      end

      TopicService.repair(poll.topic_id)
      TopicService.verify_integrity!(poll.topic_id)

      {
        poll_id: poll.id,
        topic_id: poll.topic_id,
        detached_ballot_choice_mismatches: 0,
        removed_stances: removed_stances
      }
    end
  rescue LegacyAnonymousVoteMigrationService::MigrationError, TopicService::IntegrityError => error
    raise error if error.is_a?(CleanupError)

    raise CleanupError, error.message
  end

  def self.detached_ballot_choice_mismatches(poll_id)
    AnonymousBallotChoice
      .joins(:anonymous_ballot, :poll_option)
      .where("anonymous_ballots.poll_id = :poll_id OR poll_options.poll_id = :poll_id", poll_id: poll_id)
      .where("anonymous_ballots.poll_id <> poll_options.poll_id")
      .pluck(
        "anonymous_ballot_choices.anonymous_ballot_id",
        "anonymous_ballots.poll_id",
        "poll_options.id",
        "poll_options.poll_id"
      )
  end

  def self.invalid_stance_ids(poll_id)
    cross_poll_ids = Stance
      .joins(stance_choices: :poll_option)
      .where(poll_id: poll_id)
      .where.not(poll_options: { poll_id: poll_id })
      .distinct
      .pluck(:id)

    duplicate_option_ids = StanceChoice
      .joins(:stance)
      .where(stances: { poll_id: poll_id })
      .group(:stance_id, :poll_option_id)
      .having("COUNT(*) > 1")
      .pluck(:stance_id)

    cross_poll_ids | duplicate_option_ids
  end

  def self.remove_invalid_stances!(poll:)
    stance_ids = invalid_stance_ids(poll.id)
    return 0 if stance_ids.empty?

    affected_poll_ids = StanceChoice
      .joins(:poll_option)
      .where(stance_id: stance_ids)
      .distinct
      .pluck("poll_options.poll_id")

    removed_stances = LegacyAnonymousVoteMigrationService.remove_stances!(
      poll: poll,
      stance_ids: stance_ids
    )
    Poll.where(id: affected_poll_ids | [ poll.id ]).find_each(&:update_counts!)
    removed_stances
  end

  def self.validate_poll!(poll)
    raise CleanupError, "Poll #{poll.id} is not anonymous" unless poll.anonymous?
    raise CleanupError, "Poll #{poll.id} is not stance based" unless poll.stance?
    raise CleanupError, "Poll #{poll.id} is not closed" unless poll.closed?
  end
  private_class_method :validate_poll!

  def self.format_mismatches(mismatches)
    mismatches.first(10).map do |ballot_id, ballot_poll_id, option_id, option_poll_id|
      "ballot=#{ballot_id}(poll=#{ballot_poll_id}) option=#{option_id}(poll=#{option_poll_id})"
    end.join(", ")
  end
  private_class_method :format_mismatches
end

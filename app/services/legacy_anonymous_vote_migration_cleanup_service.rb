# Some legacy anonymous polls contain stance choices for an option belonging to a
# different poll. Those choices did not contribute to the results of the poll the
# stance belonged to, but other choices on the same stance did. This service
# removes only the foreign choices, preserves the source poll's observed results,
# repairs its topic timeline, and refuses to continue if existing detached ballot
# data has ambiguous cross-poll ownership.
class LegacyAnonymousVoteMigrationCleanupService
  class CleanupError < LegacyAnonymousVoteMigrationService::MigrationError; end

  def self.cleanup!(poll:)
    Poll.transaction(requires_new: true) do
      # Serialize cleanup with voting/closing work and make all cleanup changes
      # atomic for this poll.
      poll.lock!
      validate_poll!(poll)

      # Old bugs allowed a choice to point at another poll's option. Remove only
      # that choice so valid choices and the source poll's results are retained.
      removed_stance_choices = remove_cross_poll_stance_choices!(poll: poll)

      # Detached data may already exist after an interrupted attempt. Never delete
      # a cross-poll detached choice automatically because ownership is ambiguous.
      mismatches = detached_ballot_choice_mismatches(poll.id)
      unless mismatches.empty?
        raise CleanupError, "Poll #{poll.id} has detached ballot choices for another poll: #{format_mismatches(mismatches)}"
      end

      # Removing stance events can change the event tree. Repair it now and verify
      # it before the migration service creates detached ballots.
      TopicService.repair(poll.topic_id)
      TopicService.verify_integrity!(poll.topic_id)

      {
        poll_id: poll.id,
        topic_id: poll.topic_id,
        detached_ballot_choice_mismatches: 0,
        removed_stance_choices: removed_stance_choices
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

  def self.remove_cross_poll_stance_choices!(poll:)
    choices = StanceChoice
      .joins(:stance, :poll_option)
      .where(stances: { poll_id: poll.id })
      .where.not(poll_options: { poll_id: poll.id })
    choice_ids = choices.ids
    return 0 if choice_ids.empty?

    # The foreign options may have counted these rows even though their stances
    # belong to this poll. Recalculate those polls after deleting the choices.
    affected_poll_ids = choices
      .joins(:poll_option)
      .distinct
      .pluck("poll_options.poll_id")
    affected_stance_ids = choices.distinct.pluck(:stance_id)

    StanceChoice.where(id: choice_ids).delete_all
    Stance.where(id: affected_stance_ids).find_each(&:update_option_scores!)
    Poll.where(id: affected_poll_ids).find_each(&:update_counts!)
    choice_ids.length
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

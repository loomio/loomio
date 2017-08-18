require_relative 'models/motion'
require_relative 'models/vote'
require_relative 'models/did_not_vote'
require_relative 'models/poll'

class ConvertMotionsToPolls
  def self.convert(motions:)
    # create a new poll from the motion
    puts "converting #{motions.length} motions to polls"
    Array(motions).map do |motion|
      puts motion.id
      next if motion.poll.present?
      outcome = Outcome.new(statement: motion.outcome, author: motion.outcome_author) if motion.outcome.present?

      # convert motion to poll
      poll = Poll.new(
      poll_type:               "proposal",
      poll_options_attributes: AppConfig.poll_templates.dig('proposal', 'poll_options_attributes'),
      key:                     motion.key,
      discussion:              motion.discussion,
      motion:                  motion,
      title:                   motion.name,
      details:                 motion.description,
      author_id:               motion.author_id,
      created_at:              motion.created_at,
      updated_at:              motion.updated_at,
      closing_at:              motion.closing_at,
      closed_at:               motion.closed_at,
      outcomes:                Array(outcome)
      )
      poll.save(validate: false)

      # convert votes to stances
      poll.update(
      stances: motion.votes.map do |vote|
        stance_choice = StanceChoice.new(poll_option: poll.poll_options.detect { |o| o.name == vote.position_verb })
        Stance.new(
        participant_type: 'User',
        participant_id:   vote.user_id,
        reason:           vote.statement,
        latest:           vote.age.zero?,
        created_at:       vote.created_at,
        updated_at:       vote.updated_at,
        stance_choices:   Array(stance_choice)
        )
      end
      )
      poll.update_stance_data

      # set poll to closed if motion was closed
      PollService.do_closing_work(poll: poll) if motion.closed?
    end
  end
end

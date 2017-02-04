module Development::PollsHelper

  DEFAULT_POLL_OPTION_NAMES = {
    proposal: ['agree', 'abstain', 'disagree', 'block'],
    poll:     ['grape', 'banana', 'apple'],
    check_in: ['engage']
  }.with_indifferent_access.freeze

  private

  def build_poll(poll_type: 'poll', **args)
    @poll ||= Poll.new({
      poll_type: poll_type,
      title: 'a poll title',
      details: 'some poll details',
      closing_at: 3.days.from_now,
      poll_option_names: DEFAULT_POLL_OPTION_NAMES.fetch(poll_type, []),
      discussion: test_discussion,
      author: patrick
    }.merge(args))
  end

  def existing_poll(**args)
    build_poll(args).tap(&:save).tap(&:update_stance_data)
  end

  def build_outcome(**args)
    @outcome ||= Outcome.new({
      poll: existing_poll,
      statement: "Here is an outcome"
    }.merge(args))
  end

  def existing_outcome(**args)
    build_outcome.tap(&:save)
  end
end

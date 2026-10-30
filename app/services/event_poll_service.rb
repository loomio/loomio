class EventPollService
  # A changed schedule needs fresh attendance. Keep previous responses as
  # history and install uncast replacements under the poll's topic lock.
  def self.prepare_update!(poll:, current_poll:)
    return unless poll.calendar_changes?

    poll.calendar_sequence = current_poll.calendar_sequence + 1
    return unless poll.event_schedule_changes?

    poll.stances.latest.cast.find_each do |stance|
      replacement = stance.build_replacement
      stance.update!(latest: false)
      replacement.save!
    end
  end
end

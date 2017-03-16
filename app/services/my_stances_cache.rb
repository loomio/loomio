class MyStancesCache
  attr_reader :participant, :cache

  def initialize(participant: LoggedOutUser.new, polls: [])
    @cache = {}
    return unless participant.presence && polls.presence

    Stance.latest.where(participant: participant, poll_id: polls.map(&:id)).each do |stance|
      cache[stance.poll_id] = stance
    end
  end

  def get_for(poll)
    cache.fetch(poll.id) { Stance.latest.find_by(poll: poll, participant: participant) }
  end

  def clear
    cache.clear
  end
end

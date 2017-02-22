class MyStancesCache
  attr_accessor :user, :cache

  def initialize(user: nil, polls: [])
    @user, @cache = user, {}
    return unless user && user.is_logged_in? && polls

    stances = Stance.latest.where(participant_id: user.id, poll_id: polls.map(&:id))
    stances.each { |stance| cache[stance.poll_id] = stance }
  end

  def get_for(poll)
    cache.fetch(poll.id) { Stance.latest.find_by(poll: poll, participant: user) }
  end

  def clear
    cache.clear
  end
end

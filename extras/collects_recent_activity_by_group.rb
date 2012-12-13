class CollectsRecentActivityByGroup
  attr_accessor :results

  def initialize(user, args)
    @results = {}
    since = args[:since]

    user.groups.each do |group|
      h = {}
      h[:discussions] = group.discussions.active_since(since)
      h[:motions] = group.motions_in_voting_phase
      if h[:discussions].present? or h[:motions].present?
        @results[group.full_name] = h
      end
    end
  end
end

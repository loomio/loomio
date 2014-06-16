class CollectsRecentActivityByGroup
  attr_accessor :results

  def initialize(user, args)
    @results = {}
    since = args[:since]

    user.groups.each do |group|
      h = {}
      h[:discussions] = group.discussions.active_since(since).limit(50)
      h[:motions] = group.voting_motions.limit(50)
      if h[:discussions].present? or h[:motions].present?
        @results[group.full_name] = h
      end
    end
  end
end

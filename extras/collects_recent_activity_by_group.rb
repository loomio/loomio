class CollectsRecentActivityByGroup
  def self.for(user, args)
    # { loomio: { group: group_object,
    #             discussions: [discussion objects]
    #             proposals: [proposals active record scope] }
    #
    recent_time = args[:since]
    r = {}
    r[:any_activity?] = false
    user.groups.each do |group|
      h = {}
      h[:discussions] = group.discussions.active_since(recent_time)
      h[:motions] = group.motions_in_voting_phase
      if h[:discussions] or h[:motions]
        r[:any_activity?] = true
      end
      r[group.full_name] = h
    end
    r
  end
end

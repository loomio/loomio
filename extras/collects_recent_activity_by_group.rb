class CollectsRecentActivityByGroup
  def self.for(user, args)
    # { loomio: { group: group_object,
    #             discussions: [discussion objects]
    #             proposals: [proposals active record scope] }
    #
    recent_time = args[:since]
    r = {}
    user.groups.each do |group|
      h = {}
      h[:discussions] = group.discussions.active_since(recent_time)
      h[:motions] = group.motions_in_voting_phase
      r[group.name] = h
    end
    r


  end
end

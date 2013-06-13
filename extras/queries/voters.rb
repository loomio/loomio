class Queries::Voters
  class << self
    def users_that_voted_on(motion)
      User.joins(votes: {motion: {discussion: {}}}).
           where(['motions.id = ?', motion.id])
    end

    def group_members_that_havent_voted_on(motion)
      users_that_voted = users_that_voted_on(motion)
      if users_that_voted.exists?
        motion.group.users.where(['users.id not in (?)',
                                 users_that_voted.pluck(:id)])
      else
        motion.group.users
      end
    end
  end
end

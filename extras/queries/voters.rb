class Queries::Voters
  class << self
    def users_that_voted_on(motion)
      User.joins(votes: {motion: {discussion: {}}}).
           where(['motions.id = ?', motion.id])
    end

    def group_members_that_havent_voted_on(motion)
      motion.group.users.where(['users.id not in (?)',
                               users_that_voted_on(motion).pluck(:id)])
    end
  end
end

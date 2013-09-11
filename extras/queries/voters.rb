class Queries::Voters
  class << self
    def users_that_voted_on(motion)
      User.joins(votes: {motion: {discussion: {}}}).
           where(['motions.id = ?', motion.id])
    end

    def group_members_that_havent_voted_on(motion)
      user_ids_that_voted = User.find motion.votes.pluck(:user_id)
      if user_ids_that_voted.empty?
        motion.group.users
      else
        motion.group.users.where('users.id not in (?)', user_ids_that_voted)
      end
    end
  end
end

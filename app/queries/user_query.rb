class UserQuery
  def self.visible_to(user: )
    raise "this blows up, dont use it"
    discussion_ids = DiscussionQuery.visible_to(user: user,
                                                or_public: false,
                                                or_subgroups: false).pluck('discussions.id')

    poll_ids = PollQuery.visible_to(user: user).pluck('polls.id')

    User.joins('LEFT OUTER JOIN memberships m ON m.user_id = users.id')
        .joins('LEFT OUTER JOIN discussion_readers dr ON dr.user_id = users.id')
        .joins('LEFT OUTER JOIN stances s ON s.participant_id = users.id')
        .where('m.group_id IN (:group_ids) OR
                dr.discussion_id IN (:discussion_ids) OR
                s.poll_id IN (:poll_ids)',
               {group_ids: user.group_ids,
                discussion_ids: discussion_ids,
                poll_ids: poll_ids})
  end
end

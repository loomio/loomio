class UserQuery
  def self.invitable_to(model:, actor:, q:)
    group_ids = if model.group.present?
      if model.group.admins.exists?(actor.id) ||
        (model.group.members_can_add_guests && model.group.members.exists?(actor.id))
        model.group.parent_or_self.id_and_subgroup_ids
      else
        [model.group.id]
      end
    else
      actor.group_ids
    end

    poll_ids = PollQuery.visible_to(user: actor).pluck('polls.id')

    discussion_ids = DiscussionQuery.visible_to(user: actor,
                                                or_public: false,
                                                or_subgroups: false).pluck('discussions.id')

    member_ids = User.joins('LEFT OUTER JOIN memberships m ON m.user_id = users.id').
                      where('(m.group_id IN (:group_ids))', {group_ids: group_ids}).
                      search_for(q).limit(50).pluck(:id)

    guest_ids = User.joins('LEFT OUTER JOIN discussion_readers dr ON dr.user_id = users.id').
                     where('dr.discussion_id IN (:discussion_ids) AND
                            dr.inviter_id IS NOT NULL AND
                            dr.revoked_at IS NULL', {discussion_ids: discussion_ids}).
                     search_for(q).limit(50).pluck(:id)

    voter_ids = User.joins('LEFT OUTER JOIN stances s ON s.participant_id = users.id').
                     where('s.poll_id IN (:poll_ids) AND
                            s.inviter_id IS NOT NULL AND
                            s.revoked_at IS NULL AND
                            s.latest = TRUE', {poll_ids: poll_ids}).
                     search_for(q).limit(50).pluck(:id)

    User.where(id: member_ids.concat(guest_ids).concat(voter_ids).uniq).search_for(q)
  end

  def self.visible_to(user: )
    raise "this blows up, dont use it"

    poll_ids = PollQuery.visible_to(user: user).pluck('polls.id')

    # members of groups I can see
    # user_ids_by_membership = User.joins('LEFT OUTER JOIN memberships m ON m.user_id = users.id')
    #                               .where('m.group_id IN (?)', user.group_ids)
    #
    # # guests of discussions I can see
    # user_ids_by_discussion = User.joins('LEFT OUTER JOIN discussion_readers dr ON dr.user_id = users.id')
    #                              .where('dr.discussion_id IN (?) AND
    #                                      dr.inviter_id IS NOT NULL AND
    #                                      dr.revoked_at IS NULL', discussion_ids)
    #
    # # guests of polls I can see
    # user_ids_by_stance = User.joins('LEFT OUTER JOIN stances s ON s.participant_id = users.id')
    #                          .where('s.poll_id IN (?) AND dr.inviter_id IS NOT NULL AND dr.revoked_at IS NULL', poll_ids)

    User.joins('LEFT OUTER JOIN memberships m ON m.user_id = users.id')
        .joins('LEFT OUTER JOIN discussion_readers dr ON dr.user_id = users.id')
        .joins('LEFT OUTER JOIN stances s ON s.participant_id = users.id')
        .where('(m.group_id IN (:group_ids)) OR
                (dr.discussion_id IN (:discussion_ids) AND dr.inviter_id IS NOT NULL AND dr.revoked_at IS NULL) OR
                (s.poll_id IN (:poll_ids) AND s.inviter_id IS NOT NULL AND s.revoked_at IS NULL)',
                {group_ids: user.group_ids, discussion_ids: discussion_ids, poll_ids: poll_ids })

    # so no, go for a new query mehtod, that considers target model and searches each then combines and returns
  end
end

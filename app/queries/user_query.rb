class UserQuery
  def self.invitable_to(model:, actor:, q:, limit: 50)
    group_members = search_group_members(model, actor, q)
    discussion_guests = search_discussion_guests(model, actor, q)
    poll_guests = search_poll_guests(model, actor, q)

    user_ids = [group_members, discussion_guests, poll_guests].compact.map do |relation|
      relation.limit(limit).pluck(:id)
    end.flatten

    User.where(id: user_ids).search_for(q)
  end

  def self.search_group_members(model, actor, q)
    group_ids = if model.nil?
      actor.group_ids
    else
      if model.group.present?
        if model.group.admins.exists?(actor.id) ||
          (model.group.members_can_add_guests && model.group.members.exists?(actor.id))
          model.group.parent_or_self.id_and_subgroup_ids
        else
          [model.group.id].compact
        end
      else
        if model.admins.exists?(actor.id)
          actor.group_ids
        else
          []
        end
      end
    end

    User.active.verified.joins('LEFT OUTER JOIN memberships m ON m.user_id = users.id').where('(m.group_id IN (:group_ids))', {group_ids: group_ids}).search_for(q)
  end

  def self.search_discussion_guests(model, actor, q)
    # people in my groups are already covered
    # people who are guests of discussions in my groups
    # or people in discussions where I am a guest
    discussion_ids = if model.nil?
      DiscussionQuery.visible_to(user: actor,
                                 or_public: false,
                                 or_subgroups: false).pluck('discussions.id')
    else
      if model.group.present?
        if model.group.admins.exists?(actor.id) ||
          (model.group.members_can_add_guests && model.group.members.exists?(actor.id))
          # any guests of threads within the organization
          group_ids = model.group.parent_or_self.id_and_subgroup_ids
          DiscussionQuery.visible_to(user: actor,
                                     or_public: false,
                                     group_ids: group_ids,
                                     or_subgroups: false).pluck('discussions.id')
        else
          group_ids = [model.group.id].compact
          DiscussionQuery.visible_to(user: actor,
                                     or_public: false,
                                     group_ids: group_ids,
                                     or_subgroups: false).pluck('discussions.id')
        end
      else
        if model.admins.exists?(actor.id)
          DiscussionQuery.visible_to(user: actor,
                                     or_public: false,
                                     or_subgroups: false).pluck('discussions.id')
        else
          []
        end
      end
    end

    User.joins('LEFT OUTER JOIN discussion_readers dr ON dr.user_id = users.id').
         where('dr.discussion_id IN (:discussion_ids) AND
                dr.inviter_id IS NOT NULL AND
                dr.revoked_at IS NULL', {discussion_ids: discussion_ids}).
         search_for(q)
  end

  def self.search_poll_guests(model, actor, q)
    poll_ids = if model.nil?
      PollQuery.visible_to(user: actor).pluck('polls.id')
    else
      if model.group.present?
        if model.group.admins.exists?(actor.id) ||
          (model.group.members_can_add_guests && model.group.members.exists?(actor.id))
          group_ids = model.group.parent_or_self.id_and_subgroup_ids
        else
          group_ids = [model.group.id].compact
        end
      else
        if model.admins.exists?(actor.id)
          PollQuery.visible_to(user: actor).pluck('polls.id')
        else
          []
        end
      end
    end

    voter_ids = User.joins('LEFT OUTER JOIN stances s ON s.participant_id = users.id').
                     where('s.poll_id IN (:poll_ids) AND
                            s.inviter_id IS NOT NULL AND
                            s.revoked_at IS NULL AND
                            s.latest = TRUE', {poll_ids: poll_ids}).
                     search_for(q)
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

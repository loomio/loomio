class UserQuery
  def self.group_ids_for(model, actor)
    group_ids = if model.nil?
      actor.group_ids
    else
      if model.group.present?
        if model.group.admins.exists?(actor.id) ||
          (model.group.members_can_add_guests && model.admins.exists?(actor.id)) ||
          (model.group.members_can_add_guests && model.is_a?(Poll) && !model.specified_voters_only && model.members.exists?(actor.id)) ||
          (model.group.members_can_add_guests && !model.is_a?(Poll) && model.group.members.exists?(actor.id))
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
  end

  def self.invitable_to(model:, actor:, q: nil, limit: 50)
    group_ids = group_ids_for(model, actor)

    rels = []

    rels.push User.joins('LEFT OUTER JOIN memberships m ON m.user_id = users.id').
                   where('(m.group_id IN (:group_ids))', {group_ids: group_ids})

    if model.nil? or actor.can?(:add_guests, model)
      # people who have invited actor
      rels.push(
        User.joins("LEFT OUTER JOIN discussion_readers dr on dr.inviter_id = users.id").
             where("dr.user_id = ? AND inviter_id IS NOT NULL AND revoked_at IS NULL", actor.id)
      )

      # people who have been invited by actor
      rels.push(
        User.joins("LEFT OUTER JOIN discussion_readers dr on dr.user_id = users.id").
        where("dr.inviter_id = ? AND revoked_at IS NULL", actor.id)
      )

      # people who have invited actor
      rels.push(
        User.joins("LEFT OUTER JOIN stances on stances.inviter_id = users.id").
        where("stances.participant_id = ? AND revoked_at IS NULL", actor.id)
      )

      # people who have been invited by actor
      rels.push(
        User.joins("LEFT OUTER JOIN stances on stances.participant_id = users.id").
        where("stances.inviter_id = ? AND revoked_at IS NULL", actor.id)
      )
    end

    if model.present? and actor.can?(:add_members, model)
      if model.discussion_id
        rels.push(
          User.joins('LEFT OUTER JOIN discussion_readers dr ON dr.user_id = users.id').
          where('dr.discussion_id': model.discussion_id)
        )

        rels.push(
          User.joins('LEFT OUTER JOIN stances ON stances.participant_id = users.id').
          where('stances.poll_id': model.discussion.poll_ids)
        )
      end

      if model.poll_id
        rels.push(
          User.joins('LEFT OUTER JOIN stances ON stances.participant_id = users.id').
          where('stances.poll_id': model.poll_id)
        )
      end
    end

    # an attempt to prioritize..
    # ids = []
    # rels.each do |rel|
    #   ids.concat(rel.active.verified.search_for(q).limit(limit).pluck(:id))
    #   ids = ids.flatten.uniq.compact
    #   break if ids.size >= limit
    # end

    User.where(id: rels.map { |rel| rel.active.verified.search_for(q).limit(limit).pluck(:id) }.flatten.uniq.compact).order(:memberships_count).limit(50)
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

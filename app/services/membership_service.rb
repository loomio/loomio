class MembershipService
  def self.redeem_if_pending!(membership)
    redeem(membership: membership, actor: membership.user) if membership && membership.accepted_at.nil?
  end

  def self.redeem(membership:, actor:, notify: true)
    raise Membership::InvitationAlreadyUsed.new(membership) if membership.accepted_at

    expires_at = if membership.group.parent_or_self.saml_provider
      Time.current
    else
      nil
    end

    # so we want to accept all the pending invitations this person has been sent within this org
    # and we dont want any surprises if they already have some memberships.
    # they may be accepting memberships send to a different email (unverified_user)

    group_ids = membership.group.parent_or_self.id_and_subgroup_ids
    existing_group_ids = Membership.where(user_id: actor.id).pluck(:group_id)

    Membership.pending.where(
      user_id: membership.user_id,
      group_id: (group_ids - existing_group_ids)).
    update_all(
      user_id: actor.id,
      accepted_at: DateTime.now,
      saml_session_expires_at: expires_at)

    membership.reload
    Events::InvitationAccepted.publish!(membership) if notify && membership.accepted_at
  end

  def self.update(membership:, params:, actor:)
    actor.ability.authorize! :update, membership

    membership.assign_attributes(params.slice(:title))
    return false unless membership.valid?
    membership.save!

    update_user_titles_and_broadcast(membership.id)

    EventBus.broadcast 'membership_update', membership, params, actor
  end

  def self.update_user_titles_and_broadcast(membership_id)
    membership = Membership.find(membership_id)

    user = membership.user
    group = membership.group

    return unless user && group

    titles = (user.experiences['titles'] || {})
    titles[group.id] = membership.title
    user.experiences['titles'] = titles
    user.save!
    MessageChannelService.publish_models([user], serializer: AuthorSerializer, group_id: group.id)
  end

  def self.set_volume(membership:, params:, actor:)
    actor.ability.authorize! :update, membership
    val = Membership.volumes[params[:volume]]
    if params[:apply_to_all]
      group_ids = membership.group.parent_or_self.id_and_subgroup_ids
      actor.memberships.where(group_id: group_ids).update_all(volume: val)
      actor.discussion_readers.joins(:discussion).
            where('discussions.group_id': group_ids).
            update_all(volume: val)
      Stance.joins(:poll).
             where('polls.group_id': group_ids).
             where(participant_id: actor.id).
             update_all(volume: val)
    else
      membership.set_volume! params[:volume]
      membership.discussion_readers.update_all(volume: val)
      membership.stances.update_all(volume: val)
    end
  end

  def self.resend(membership:, actor:)
    actor.ability.authorize! :resend, membership
    EventBus.broadcast 'membership_resend', membership, actor
    Events::MembershipResent.publish!(membership, actor)
  end

  def self.make_admin(membership:, actor:)
    actor.ability.authorize! :make_admin, membership
    membership.update admin: true
    Events::NewCoordinator.publish!(membership, actor)
  end

  def self.remove_admin(membership:, actor:)
    actor.ability.authorize! :remove_admin, membership
    membership.update admin: false
  end

  def self.join_group(group:, actor:)
     actor.ability.authorize! :join, group
     membership = group.add_member!(actor)
     EventBus.broadcast('membership_join_group', group, actor)
     Events::UserJoinedGroup.publish!(membership)
   end

  def self.add_users_to_group(users:, group:, inviter:)
    inviter.ability.authorize!(:add_members, group)
    group.add_members!(users, inviter: inviter).tap do |memberships|
      Events::UserAddedToGroup.bulk_publish!(memberships, user: inviter)
    end
  end

  def self.destroy(membership:, actor:)
    actor.ability.authorize! :destroy, membership
    now = Time.zone.now

    DiscussionReader.joins(:discussion).where(
      'discussions.group_id': membership.group.id_and_subgroup_ids,
      user_id: membership.user_id).update_all(revoked_at: now)

    Stance.joins(:poll).where(
      'polls.group_id': membership.group.id_and_subgroup_ids,
      participant_id: membership.user_id,
      cast_at: nil
    ).update_all(revoked_at: now)

    Membership.where(user_id: membership.user_id, group_id: membership.group.id_and_subgroup_ids).destroy_all

    EventBus.broadcast('membership_destroy', membership, actor)
  end

  def self.save_experience(membership:, actor:, params:)
    actor.ability.authorize! :update, membership
    membership.experienced!(params[:experience])
    EventBus.broadcast('membership_save_experience', membership, actor, params)
  end
end

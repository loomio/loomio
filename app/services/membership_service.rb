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

    existing_membership = Membership.where("id != ?", membership.id).where(group_id: membership.group_id, user_id: actor.id).first
    update_success = membership.update(user: actor, accepted_at: DateTime.now, saml_session_expires_at: expires_at)

    if membership.inviter
      Group.where(id: Array(membership.experiences['invited_group_ids'])).each do |group|
        group.add_member!(actor, inviter: membership.inviter) if membership.inviter.can?(:add_members, group)
      end
    end

    if existing_membership && !update_success
      membership.destroy
    end

    Events::InvitationAccepted.publish!(membership) if notify
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
    MessageChannelService.publish_data(AuthorSerializer.new(user).as_json, to: group.message_channel)
  end

  def self.set_volume(membership:, params:, actor:)
    actor.ability.authorize! :update, membership
    if params[:apply_to_all]
      actor.memberships.where(group_id: membership.group.parent_or_self.id_and_subgroup_ids).update_all(volume: Membership.volumes[params[:volume]])
      actor.discussion_readers.update_all(volume: nil)
    else
      membership.set_volume! params[:volume]
      membership.discussion_readers.update_all(volume: nil)
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
      participant_id: membership.user_id).update_all(revoked_at: now)

    Membership.where(user_id: membership.user_id, group_id: membership.group.id_and_subgroup_ids).destroy_all

    EventBus.broadcast('membership_destroy', membership, actor)
  end

  def self.save_experience(membership:, actor:, params:)
    actor.ability.authorize! :update, membership
    membership.experienced!(params[:experience])
    EventBus.broadcast('membership_save_experience', membership, actor, params)
  end
end

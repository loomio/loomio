class MembershipService
  def self.redeem(membership:, actor:)
    raise Membership::InvitationAlreadyUsed.new(membership) if membership.accepted_at

    expires_at = if membership.group.is_formal_group? && membership.group.parent_or_self.saml_provider?
      Time.current
    else
      nil
    end

    membership.update(user: actor, accepted_at: DateTime.now, saml_session_expires_at: expires_at)

    if membership.inviter
      membership.inviter.groups.where(id: Array(membership.experiences['invited_group_ids'])).each do |group|
        group.add_member!(actor, inviter: membership.inviter) if membership.inviter.can?(:add_members, group)
      end
    end

    Events::InvitationAccepted.publish!(membership)
  end

  def self.update(membership:, params:, actor:)
    actor.ability.authorize! :update, membership

    membership.assign_attributes(params.slice(:title))
    return false unless membership.valid?
    membership.save!

    EventBus.broadcast 'membership_update', membership, params, actor
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
    membership.destroy
    EventBus.broadcast('membership_destroy', membership, actor)
  end

  def self.save_experience(membership:, actor:, params:)
    actor.ability.authorize! :update, membership
    membership.experienced!(params[:experience])
    EventBus.broadcast('membership_save_experience', membership, actor, params)
  end
end

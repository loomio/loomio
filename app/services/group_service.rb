module GroupService
  DEFAULT_COVER_PHOTO_FILENAMES = %w[
    cover1.jpg
    cover2.jpg
    cover3.jpg
    cover4.jpg
    cover5.jpg
    cover6.jpg
    cover7.jpg
    cover8.jpg
    cover9.jpg
    cover10.jpg
    cover11.jpg
    cover12.jpg
    cover13.jpg
    cover14.jpg
  ]
  def self.remote_cover_photo
    Rails.root.join("public/theme/group_cover_photos/#{DEFAULT_COVER_PHOTO_FILENAMES.sample}")
  end

  def self.invite(group:, params:, actor:)
    group_ids = if params[:invited_group_ids]
      Array(params[:invited_group_ids]).map(&:to_i)
    else
      Array(group.id)
    end

    # restrict group_ids to a single organization
    parent_group = Group.where(id: group_ids).first.parent_or_self
    group_ids = parent_group.id_and_subgroup_ids & group_ids

    UserInviter.authorize_add_members!(
      parent_group: parent_group,
      group_ids: group_ids,
      emails: Array(params[:recipient_emails]),
      user_ids: Array(params[:recipient_user_ids]),
      actor: actor
    )

    users = UserInviter.where_or_create!(
      actor: actor,
      model: group,
      emails: params[:recipient_emails],
      user_ids: params[:recipient_user_ids]
    )

    Group.where(id: group_ids).each do |g|
      revoked_memberships = Membership.revoked.where(group_id: g.id, user_id: users.map(&:id))
      revoked_memberships.update_all(
        inviter_id: actor.id,
        accepted_at: nil,
        revoked_at: nil,
        revoker_id: nil,
        admin: false,
      )

      new_memberships = users.map do |user|
        Membership.new(inviter: actor, user: user, group: g, volume: user.default_membership_volume)
      end

      Membership.import(new_memberships, on_duplicate_key_ignore: true)

      # mark as accepted all invitiations to people who are already part of the org.
      other_group_ids = Group.published.where(id: g.parent_or_self.id_and_subgroup_ids).pluck(:id) - Array(g.id)
      existing_member_ids = Membership.accepted.where(group_id: other_group_ids, user_id: users.verified.pluck(:id)).pluck(:user_id)
      Membership.pending.where(group_id: g.id, user_id: existing_member_ids).update_all(accepted_at: Time.now)

      g.update_pending_memberships_count
      g.update_memberships_count
      PollGroupMembersAddedWorker.perform_later(g.id)
    end

    Events::MembershipCreated.publish!(
      group: group,
      actor: actor,
      recipient_user_ids: users.pluck(:id),
      recipient_message: params[:recipient_message]
    )

    Sentry.metrics.count("membership.invite", attributes: { recipient_count: users.size })
    Membership.active.where(group_id: group.id, user_id: users.pluck(:id))
  end

  def self.create(group:, actor: , skip_authorize: false)
    actor.ability.authorize!(:create, group) unless skip_authorize

    unless group.valid?
      Sentry.metrics.count("group.create_failed", attributes: { columns: group.errors.attribute_names.join(',') })
      return false
    end

    if group.is_parent?
      url = remote_cover_photo
      group.cover_photo.attach(io: URI.open(url), filename: File.basename(url))
      group.creator = actor if actor.is_logged_in?
      group.subscription = Subscription.new
    end

    group.save!
    group.add_admin!(actor)

    Sentry.metrics.count("group.create", attributes: { is_subgroup: !group.is_parent? })
    EventBus.broadcast('group_create', group, actor)
  end

  def self.update(group:, params:, actor:)
    actor.ability.authorize! :update, group

    old_handle = group.handle
    group.assign_attributes_and_files(params.except(:parent_id))
    group.group_privacy = params[:group_privacy] if params.has_key?(:group_privacy)
    privacy_change = PrivacyChange.new(group)

    unless group.valid?
      Sentry.metrics.count("group.update_failed", attributes: { columns: group.errors.attribute_names.join(',') })
      return false
    end

    Group.transaction do
      group.save!

      new_handle = group.handle
      if old_handle.present? && new_handle.present? && old_handle != new_handle
        GroupHandleRedirect.find_or_create_by!(group: group, handle: old_handle)
        trim_handle_redirects(group)
      end
    end

    privacy_change.commit!

    Sentry.metrics.count("group.update")
    EventBus.broadcast('group_update', group, params, actor)
  end

  def self.destroy(group:, actor:)
    actor.ability.authorize! :destroy, group

    group.admins.each do |admin|
      GroupMailer.destroy_warning(group.id, admin.id, actor.id).deliver_later
    end

    group.archive!

    Sentry.metrics.count("group.destroy")
    DestroyGroupWorker.set(wait: 2.weeks).perform_later(group.id)
    EventBus.broadcast('group_destroy', group, actor)
  end

  def self.destroy_without_warning!(group_id)
    Group.find(group_id).archive!
    DestroyGroupWorker.perform_later(group_id)
  end

  def self.move(group:, parent:, actor:)
    actor.ability.authorize! :move, group
    old_handle = group.handle
    if group.handle?
      new_handle = "#{parent.handle}-#{group.handle}"
      group.update(handle: new_handle)
      if old_handle.present? && old_handle != new_handle
        GroupHandleRedirect.find_or_create_by!(group: group, handle: old_handle)
        trim_handle_redirects(group)
      end
    end
    group.update(parent: parent, subscription_id: nil)
    EventBus.broadcast('group_move', group, parent, actor)
  end

  def self.export(group: , actor: )
    actor.ability.authorize! :show, group
    group_ids = actor.groups.where(id: group.all_groups).pluck(:id)
    Sentry.metrics.count("group.export")
    GroupExportWorker.perform_later(group_ids, group.name, actor.id)
  end

  def self.merge(source:, target:, actor:)
    actor.ability.authorize! :merge, source
    actor.ability.authorize! :merge, target

    Group.transaction do
      source.subgroups.update_all(parent_id: target.id)
      Topic.where(group_id: source.id).update_all(group_id: target.id)
      source.membership_requests.update_all(group_id: target.id)
      source.memberships.where.not(user_id: target.member_ids).update_all(group_id: target.id)
      source.destroy
    end
  end

  def self.suggest_handle(name:, parent_handle:)
    attempt = 0
    while(Group.where(handle: generate_handle(name, parent_handle, attempt)).exists? ||
         GroupHandleRedirect.where(handle: generate_handle(name, parent_handle, attempt)).exists?) do
      attempt += 1
    end
    generate_handle(name, parent_handle, attempt)
  end

  def self.update_handle(group:, handle:, actor:)
    actor.ability.authorize! :update, group

    old_handle = group.handle
    new_handle = handle.to_s.strip.parameterize.presence

    Group.transaction do
      group.update!(handle: new_handle)

      if old_handle.present? && old_handle != new_handle
        GroupHandleRedirect.find_or_create_by!(
          group: group,
          handle: old_handle
        )
        trim_handle_redirects(group)
      end
    end

    if old_handle.present? && old_handle != new_handle
      UpdateDescendantHandlesWorker.perform_later(group.id, old_handle, new_handle)
    end

    old_handle
  end

  def self.update_descendant_handles(group_id, old_parent_handle, new_parent_handle)
    group = Group.find(group_id)
    group.all_subgroups.each do |subgroup|
      old_sub_handle = subgroup.handle
      next unless old_sub_handle&.starts_with?("#{old_parent_handle}-")

      new_sub_handle = old_sub_handle.sub(
        /\A#{Regexp.escape(old_parent_handle)}-/,
        "#{new_parent_handle}-"
      )

      subgroup.update!(handle: new_sub_handle)

      GroupHandleRedirect.find_or_create_by!(
        group: subgroup,
        handle: old_sub_handle
      )
      trim_handle_redirects(subgroup)

      update_descendant_handles(subgroup.id, old_sub_handle, new_sub_handle)
    end
  end

  private

  def self.trim_handle_redirects(group)
    excess = group.handle_redirects.order(created_at: :desc).offset(3)
    excess.destroy_all if excess.any?
  end

  def self.generate_handle(name, parent_handle, attempt)
    [parent_handle,
     name,
     (attempt == 0) ? nil : attempt].compact.map{|t| t.to_s.strip.parameterize}.join('-')
  end
end

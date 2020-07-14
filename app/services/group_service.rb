module GroupService
  def self.announce(group:, params:, actor:)
    actor.ability.authorize! :announce, group

    groups = Group.where(id: Array(params[:invited_group_ids]).map(&:to_i).concat([group.id]))

    users = UserInviter.where_or_create!(inviter: actor,
                                         emails: params[:emails],
                                         user_ids: params[:user_ids])

    groups.each do |g|
      next unless actor.can?(:add_members, g)

      memberships = users.map do |user|
        Membership.new(inviter: actor, user: user, group: g, volume: 2)
      end

      Membership.import(memberships, on_duplicate_key_ignore: true)

      # mark as accepted all invitiations to people who are already part of the org.
      if g.parent
        parent_members = g.parent.accepted_members.where(id: users.verified.pluck(:id))
        Membership.pending.where(group_id: g.id,
                                 user_id: parent_members.pluck(:id)).update_all(accepted_at: Time.now)
      end

      g.update_pending_memberships_count
      g.update_memberships_count
    end

    # email should say, so and so has invited you to the following loomio groups.
    # or so and so has added you to the following loomio groups.
    all_memberships = Membership.not_archived.where(group_id: group.id, user_id: users.pluck(:id))
    Events::AnnouncementCreated.publish!(group, actor, all_memberships)
    all_memberships
  end

  def self.create(group:, actor: )
    actor.ability.authorize! :create, group

    return false unless group.valid?

    group.is_referral = actor.groups.size > 0

    if group.is_parent?
      group.default_group_cover = DefaultGroupCover.sample
      group.creator             = actor if actor.is_logged_in?
      ExampleContent.new(group).add_to_group! if AppConfig.app_features[:example_content]
    end

    group.update_attachments!
    group.save!
    group.add_admin!(actor)

    EventBus.broadcast('group_create', group, actor)
  end

  def self.update(group:, params:, actor:)
    actor.ability.authorize! :update, group

    params[:features].reject! { |_,v| v.blank? } if params.has_key?(:features)
    HasRichText.assign_attributes_and_update_files(group, params)
    group.group_privacy = params[:group_privacy] if params.has_key?(:group_privacy)
    privacy_change = PrivacyChange.new(group)

    return false unless group.valid?
    group.update_attachments!
    group.save!
    privacy_change.commit!

    EventBus.broadcast('group_update', group, params, actor)
  end

  def self.destroy(group:, actor:)
    actor.ability.authorize! :destroy, group
    group.archive!
    DestroyGroupWorker.perform_in(2.weeks, group.id)
    EventBus.broadcast('group_destroy', group, actor)
  end

  def self.move(group:, parent:, actor:)
    actor.ability.authorize! :move, group
    group.update(handle: "#{parent.handle}-#{group.handle}") if group.handle?
    group.update(parent: parent, subscription_id: nil)
    EventBus.broadcast('group_move', group, parent, actor)
  end

  def self.export(group: , actor: )
    actor.ability.authorize! :show, group
    group_ids = actor.groups.where(id: group.all_groups).pluck(:id)
    GroupExportWorker.perform_async(group_ids, group.name, actor.id)
  end

  def self.merge(source:, target:, actor:)
    actor.ability.authorize! :merge, source
    actor.ability.authorize! :merge, target

    Group.transaction do
      source.subgroups.update_all(parent_id: target.id)
      source.discussions.update_all(group_id: target.id)
      source.polls.update_all(group_id: target.id)
      source.membership_requests.update_all(group_id: target.id)
      source.group_identities.update_all(group_id: target.id)
      source.memberships.where.not(user_id: target.member_ids).update_all(group_id: target.id)
      source.destroy
    end
  end

  def self.suggest_handle(name:, parent_handle:)
    attempt = 0
    while(Group.where(handle: generate_handle(name, parent_handle, attempt)).exists?) do
      attempt += 1
    end
    generate_handle(name, parent_handle, attempt)
  end

  private

  def self.generate_handle(name, parent_handle, attempt)
    [parent_handle,
     name,
     (attempt == 0) ? nil : attempt].compact.map{|t| t.to_s.strip.parameterize}.join('-')
  end
end

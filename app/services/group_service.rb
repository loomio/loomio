module GroupService
  def self.announce(group:, params:, actor:)
    actor.ability.authorize! :announce, group

    invited_group_ids = Array(params[:invited_group_ids]).map(&:to_i)

    users = UserInviter.where_or_create!(inviter: actor,
                                         emails: params[:emails],
                                         user_ids: params[:user_ids])

    new_memberships = users.where.not(id: group.all_member_ids).map do |user|
      Membership.new inviter: actor,
                     user: user,
                     group: group,
                     volume: 2,
                     experiences: {invited_group_ids: invited_group_ids}.compact
    end

    Membership.import(new_memberships, on_duplicate_key_ignore: true)

    memberships = Membership.where(group: group, user_id: users.pluck(:id))

    group.update_pending_memberships_count
    group.update_memberships_count
    Events::AnnouncementCreated.publish!(group, actor, memberships)
    Membership.where(user_id: users.pluck(:id), group_id: group.id)
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

    group.save!
    group.update_attachments!
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
    group.save!
    group.update_attachments!
    privacy_change.commit!

    EventBus.broadcast('group_update', group, params, actor)
  end

  def self.archive(group:, actor:)
    actor.ability.authorize! :archive, group
    group.archive!
    EventBus.broadcast('group_archive', group, actor)
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

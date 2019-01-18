module GroupService
  def self.create(group:, actor: )
    actor.ability.authorize! :create, group

    return false unless group.valid?

    group.is_referral = actor.groups.size > 0

    if group.is_formal_group? && group.is_parent?
      group.default_group_cover = DefaultGroupCover.sample
      group.creator             = actor if actor.is_logged_in?
      ExampleContent.new(group).add_to_group! if AppConfig.app_features[:help_link]
    end

    group.save!

    EventBus.broadcast('group_create', group, actor)
  end

  def self.update(group:, params:, actor:)
    actor.ability.authorize! :update, group

    params[:features].reject! { |_,v| v.blank? } if params.has_key?(:features)
    group.assign_attributes(params)
    group.group_privacy = params[:group_privacy] if params.has_key?(:group_privacy)
    privacy_change = PrivacyChange.new(group)

    return false unless group.valid?
    group.save!
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
    group.update(parent: parent, subscription_id: nil)
    EventBus.broadcast('group_move', group, parent, actor)
  end

  def self.export(group: , actor: )
    actor.ability.authorize! :show, group
    group_ids = actor.groups.where(id: group.all_groups).pluck(:id)
    GroupExportJob.perform_later(group_ids: group_ids, actor: actor, group_name: group.name)
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

      existing_visit_ids = GroupVisit.where(group_id: target.id).pluck(:user_id)
      GroupVisit.where(group_id: source.id)
                .where.not(user_id: existing_visit_ids)
                .update_all(group_id: target.id)

      existing_org_visit_ids = OrganisationVisit.where(organisation_id: target.id).pluck(:user_id)
      OrganisationVisit.where(organisation_id: source.id)
                       .where.not(user_id: existing_org_visit_ids)
                       .update_all(organisation_id: target.id)

      source.destroy
    end
  end
end

module GroupService
  def self.remote_cover_photo
    # id like to use unsplash api but need to work out how to meet their attribution requirements
    filename = %w[
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
    ].sample
    Rails.root.join("public/theme/group_cover_photos/#{filename}")
  end

  def self.invite(group:, params:, actor:)
    group_ids = if params[:invited_group_ids]
      Array(params[:invited_group_ids])
    else
      Array(group.id)
    end

    groups = Group.where(id: group_ids).each { |g| actor.ability.authorize!(:add_members, g) }

    users = UserInviter.where_or_create!(actor: actor,
                                         model: group,
                                         emails: params[:recipient_emails],
                                         user_ids: params[:recipient_user_ids])

    groups.each do |g|
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

    Events::MembershipCreated.publish!(
      group: group,
      actor: actor,
      recipient_user_ids: users.pluck(:id),
      recipient_message: params[:recipient_message])

    # EventBus.broadcast('group_invite', group, actor, all_memberships.size)
    Membership.not_archived.where(group_id: group.id, user_id: users.pluck(:id))

  end

  def self.create(group:, actor: )
    actor.ability.authorize! :create, group

    return false unless group.valid?

    group.is_referral = actor.groups.size > 0

    if group.is_parent?
      url = remote_cover_photo
      group.cover_photo.attach(io: URI.open(url), filename: File.basename(url))
      group.creator = actor if actor.is_logged_in?

      if template_group = Group.find_by(handle: 'trial-group-template')
        cloner = RecordCloner.new(recorded_at: template_group.discussions.last.updated_at)
        cloner.clone_trial_content_into_group(group, actor)
      end
      group.subscription = Subscription.new
    end

    group.save!
    group.add_admin!(actor)

    EventBus.broadcast('group_create', group, actor)
  end

  def self.update(group:, params:, actor:)
    actor.ability.authorize! :update, group

    group.assign_attributes_and_files(params)
    group.group_privacy = params[:group_privacy] if params.has_key?(:group_privacy)
    privacy_change = PrivacyChange.new(group)

    return false unless group.valid?
    group.save!
    privacy_change.commit!

    EventBus.broadcast('group_update', group, params, actor)
  end

  def self.destroy(group:, actor:)
    actor.ability.authorize! :destroy, group

    group.admins.each do |admin|
      GroupMailer.destroy_warning(group.id, admin.id, actor.id).deliver_later
    end

    group.archive!

    DestroyGroupWorker.perform_in(2.weeks, group.id)
    EventBus.broadcast('group_destroy', group, actor)
  end

  def self.destroy_without_warning!(group_id)
    Group.find(group_id).archive!
    DestroyGroupWorker.perform_async(group_id)
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

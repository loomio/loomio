# require 'uri'

module GroupService

  def self.remote_cover_photo
    # id like to use unsplash api but need to work out how to meet their attribution requirements
    [
      "https://loomio-uploads.s3.amazonaws.com/default_group_covers/cover_photos/000/000/001/original/open-uri20150904-3-16e2exd?1441337903",
      "https://loomio-uploads.s3.amazonaws.com/default_group_covers/cover_photos/000/000/002/original/open-uri20150904-3-rdqbrq?1441337903",
      "https://loomio-uploads.s3.amazonaws.com/default_group_covers/cover_photos/000/000/003/original/open-uri20150904-3-1oppl5v?1441337903",
      "https://loomio-uploads.s3.amazonaws.com/default_group_covers/cover_photos/000/000/004/original/open-uri20150904-3-pk5rt7?1441337903",
      "https://loomio-uploads.s3.amazonaws.com/default_group_covers/cover_photos/000/000/005/original/open-uri20150904-3-llrp8p?1441337904",
      "https://loomio-uploads.s3.amazonaws.com/default_group_covers/cover_photos/000/000/006/original/open-uri20150904-3-12f1pb7?1441337904",
      "https://loomio-uploads.s3.amazonaws.com/default_group_covers/cover_photos/000/000/007/original/open-uri20150904-3-mnvdi7?1441337904",
      "https://loomio-uploads.s3.amazonaws.com/default_group_covers/cover_photos/000/000/008/original/open-uri20150904-3-ug7qk8?1441337904",
      "https://loomio-uploads.s3.amazonaws.com/default_group_covers/cover_photos/000/000/009/original/open-uri20150904-3-kxuccv?1441337904",
      "https://loomio-uploads.s3.amazonaws.com/default_group_covers/cover_photos/000/000/010/original/open-uri20150904-3-1v5vy0t?1441337904",
      "https://loomio-uploads.s3.amazonaws.com/default_group_covers/cover_photos/000/000/011/original/open-uri20150904-3-nk5ttf?1441337905",
      "https://loomio-uploads.s3.amazonaws.com/default_group_covers/cover_photos/000/000/012/original/open-uri20150904-3-12mh2l4?1441337905",
      "https://loomio-uploads.s3.amazonaws.com/default_group_covers/cover_photos/000/000/013/original/open-uri20150904-3-1rh3y2o?1441337905",
      "https://loomio-uploads.s3.amazonaws.com/default_group_covers/cover_photos/000/000/014/original/open-uri20150904-3-18nwpr9?1441337905"
    ].sample
  end

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
    group.creator = actor if actor.is_logged_in?

    if group.is_parent?
      if Rails.env.production?
        url = remote_cover_photo
        group.cover_photo.attach(io: URI.open(url), filename: File.basename(URI.parse(url).path))
      end

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

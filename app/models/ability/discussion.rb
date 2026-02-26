module Ability::Discussion
  def initialize(user)
    super(user)

    can [:show,
         :print,
         :dismiss], ::Discussion do |discussion|
      DiscussionQuery.visible_to(user: user).exists?(discussion.id)
    end

    can :update_version, ::Discussion do |discussion|
      discussion.author == user or discussion.admins.exists?(user.id)
    end

    can :create, ::Discussion do |discussion|
      topic = discussion.topic
      group = topic.group
      user.email_verified? &&
      (
        (group.blank? && (!AppConfig.app_features[:create_user] || user.group_ids.any?)) ||
        group.admins.exists?(user.id) ||
        (group.members_can_start_discussions && group.members.exists?(user.id))
      )
    end

    can [:announce], ::Discussion do |discussion|
      if discussion.group_id
        discussion.group.admins.exists?(user.id) ||
        (discussion.group.members_can_announce && discussion.members.exists?(user.id))
      else
        discussion.topic.admins_include?(user)
      end
    end

    can [:update, :move], ::Discussion do |discussion|
      discussion.discarded_at.nil? &&
      (discussion.author == user ||
      discussion.admins.exists?(user.id) ||
      (discussion.group.members_can_edit_discussions && discussion.members.exists?(user.id)))
    end

    can [:destroy, :discard], ::Discussion do |discussion|
      discussion.discarded_at.nil? &&
      (discussion.author == user || discussion.admins.exists?(user.id))
    end
  end
end

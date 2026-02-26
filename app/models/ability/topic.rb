module Ability::Topic
  def initialize(user)
    super(user)

    can [:show, :mark_as_seen, :mark_as_read, :dismiss, :set_volume], ::Topic do |topic|
      can?(:show, topic.topicable)
    end

    can [:update, :move, :move_comments, :pin, :close, :reopen, :discard], ::Topic do |topic|
      topic.admins_include?(user)
    end

    can [:announce], ::Topic do |topic|
      group = topic.group
      if topic.group_id
        group.admins_include?(user) ||
        (group.members_can_announce && group.members_include?(user))
      else
        topic.admins_include?(user)
      end
    end

    can [:add_members], ::Topic do |topic|
      group = topic.group
      if topic.group_id
        group.members_include?(user)
      else
        topic.members_include?(user)
      end
    end

    can [:add_guests], ::Topic do |topic|
      group = topic.group
      if topic.group_id
        Subscription.for(group).allow_guests &&
        (group.admins_include?(user) || (group.members_can_add_guests && group.members_include?(user)))
      else
        topic.admins_include?(user)
      end
    end
  end
end

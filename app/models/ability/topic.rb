module Ability::Topic
  def initialize(user)
    super(user)

    can [:show, :mark_as_seen, :mark_as_read, :dismiss, :set_volume], ::Topic do |topic|
      can?(:show, topic.topicable)
    end

    # An export would show the votes in any open poll that hides results until
    # the reader votes, so wait until the reader has voted in each one.
    can [:export], ::Topic do |topic|
      voted_poll_ids = ::Stance.latest.decided.where(participant_id: user.id).select(:poll_id)
      can?(:show, topic) &&
      !topic.polls.active.where(hide_results: :until_vote).where.not(id: voted_poll_ids).exists?
    end

    can [:update, :move, :move_comments, :pin, :close, :reopen, :discard], ::Topic do |topic|
      topic.admins_include?(user)
    end

    can [:update_tags], ::Topic do |topic|
      topic.topicable.present? && can?(:update, topic.topicable)
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

    can [:members_autocomplete], ::Topic do |topic|
      topic.members_include?(user) && (topic.group_id.nil? || user.email_verified?)
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

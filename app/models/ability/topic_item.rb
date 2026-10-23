module Ability
  module TopicItem
    def initialize(user)
      super(user)

      can :update_tags, ::TopicItem do |item|
        topic = item.topic
        user.is_logged_in? && user.deactivated_at.nil? && item.taggable? &&
          !topic.locked_at && !topic.discarded_at && can?(:show, topic) &&
          item.tags_assignable? && topic.members_include?(user) &&
          (topic.admins_include?(user) || item.itemable.author_id == user.id ||
            (item.kind == 'new_discussion' && topic.group.members_can_edit_discussions))
      end

      can [:pin, :unpin], ::TopicItem do |topic_item|
        can?(:update, topic_item.topic)
      end
    end
  end
end

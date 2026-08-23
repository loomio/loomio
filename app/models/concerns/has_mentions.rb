module HasMentions
  extend ActiveSupport::Concern
  include HasTopicItems

  module ClassMethods
    def is_mentionable(on: [])
      define_singleton_method :mentionable_fields, -> { Array on }
    end
  end

  def mentioned_usernames
    if text_format == "md"
      MentionParser.usernames(mentionable_text) - [self.author&.username]
    else
      Nokogiri::HTML::fragment(mentionable_text).search("span[data-mention-id]").map do |el|
        el['data-mention-id']
      end.filter { |id_or_username| id_or_username.to_i.to_s != id_or_username }
    end
  end

  def mentioned_user_ids
    # html text could use ids or usernames depending on the age of the content
    return [] if text_format == "md"

    Nokogiri::HTML::fragment(mentionable_text).search("span[data-mention-id]").map do |el|
      el['data-mention-id']
    end.filter { |id_or_username| id_or_username.to_i.to_s == id_or_username }
  end

  def mentioned_users
    topic.members.where("users.username in (:usernames) or users.id in (:ids)",
                        usernames: mentioned_usernames, ids: mentioned_user_ids)
  end

  def mentioned_group_users
    User.active.verified.where(id: Membership.active.accepted.where(group_id: mentioned_groups.pluck(:id)).pluck(:user_id))
  end

  def mentioned_groups
    # for now, we only allow mentioning the current group, if the actor is permitted
    group_ids = Group.published.where(id: topic.group_id).where(handle: mentioned_usernames).filter { |group| author.can? :notify, group }.map(&:id)
    Group.where(id: group_ids)
  end

  def newly_mentioned_groups
    mentioned_groups.where.not(id: already_mentioned_group_ids)
  end

  def newly_mentioned_users
    mentioned_users.where.not(id: already_mentioned_user_ids) # avoid re-mentioning users when editing
  end

  # users mentioned on a previous edit of this model
  def already_mentioned_user_ids
    mention_notifications = Notification.user_mentions.where(subject: self)
    snapshotted_user_ids = mention_notifications.pluck(:recipient_user_ids).flatten
    delivery_user_ids = NotificationDelivery
                        .where(
                          notification_id: mention_notifications.select(:id),
                          recipient_type: "User",
                          channel: "in_app"
                        )
                        .pluck(:recipient_id)
    (snapshotted_user_ids + delivery_user_ids).compact.map(&:to_i).uniq
  end

  def already_mentioned_group_ids
    legacy_group_ids = topic_items.where(kind: "group_mentioned")
                             .flat_map { |topic_item| topic_item.custom_fields["group_ids"] }
    notification_group_ids = Notification.where(
      kind: "group_mentioned",
      subject: self
    ).flat_map { |notification| notification.audience_values["group_ids"] }
    (legacy_group_ids + notification_group_ids).compact.map(&:to_i).uniq
  end

  private

  def text_format
    send("#{self.class.mentionable_fields.first}_format")
  end

  def mentionable_text
    self.class.mentionable_fields.map { |field| send(field) }.join('|')
  end
end

class NotificationSerializer < ApplicationSerializer
  attributes :id,
             :viewed,
             :created_at,
             :url,
             :kind,
             :actor_id,
             :event_id,
             :name,
             :title,
             :poll_type,
             :reaction,
             :model

  has_one :actor, serializer: AuthorSerializer, root: :users

  def name
    tv :name
  end

  def title
    tv :title
  end

  def poll_type
    tv :poll_type
  end

  def reaction
    tv :reaction
  end

  def model
    tv :model
  end

  def tv(key)
    object.translation_values[key.to_s]
  end

  def kind
    if event.kind == "comment_announced"
      return 'comment_announced_to_group' if event.custom_fields['audiences'].include? Audience.group.name

      return 'comment_announced_to_discussion' if event.custom_fields['audiences'].include? Audience.discussion.name
    elsif event.kind == "announcement_created"
      event.custom_fields['kind'] || "group_announced"
    elsif event.kind == 'user_mentioned' &&
       event.eventable.respond_to?(:parent) &&
       event.eventable.parent.present? &&
       event.eventable.parent.author == object.user
      "comment_replied_to"
    else
      event.kind
    end
  end
end

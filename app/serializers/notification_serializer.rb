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

  def url
    event.notification_url
  end

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
    object.kind
  end
end

class NotificationSerializer < ApplicationSerializer
  attributes :id,
             :viewed,
             :created_at,
             :url,
             :kind,
             :topic_id,
             :sequence_id,
             :actor_id,
             :name,
             :title,
             :poll_type,
             :reaction,
             :model

  def url
    object.notification_url
  end

  def viewed
    object.viewed_for?(scope[:current_user_id])
  end

  def topic_id
    read_topic_item&.topic_id
  end

  def sequence_id
    read_topic_item&.sequence_id
  end

  def read_topic_item
    cache_fetch(:notification_topic_items_by_id, object.id) { object.read_topic_item }
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
    object.translation_values_for(scope[:current_user_id])[key.to_s]
  end

  def kind
    object.kind
  end
end

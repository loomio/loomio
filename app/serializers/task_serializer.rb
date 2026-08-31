class TaskSerializer < ApplicationSerializer
  attributes :id,
             :name,
             :author_id,
             :uid,
             :done,
             :done_at,
             :due_on,
             :record_type,
             :record_id

  has_one :record, polymorphic: true, key: 'record_obj'
  has_one :author, serializer: AuthorSerializer, root: :users
  has_one :topic, serializer: TopicSerializer, root: :topics

  def topic
    object.record.topic
  end

  def include_topic?
    object.record.is_a?(Comment)
  end
end

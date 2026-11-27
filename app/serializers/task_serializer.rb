class TaskSerializer < ApplicationSerializer
  attributes :id,
             :name,
             :author_id,
             :uid,
             :done_at,
             :due_on,
             :record_type,
             :record_id,
             :assignee_ids

  has_one :record, polymorphic: true, key: 'record_obj'
  has_one :author, serializer: AuthorSerializer, root: :users
  has_one :topic, serializer: TopicSerializer, root: :topics

  def assignee_ids
    object.tasks_users.map(&:user_id)
  end

  def topic
    object.record.topic
  end

  def include_topic?
    object.record.is_a?(Comment)
  end
end

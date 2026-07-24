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

  def record_id
    return object.record_id unless object.anonymous_stance?

    Stance.anonymous_id_for(poll_id: object.record.poll_id, stance_id: object.record_id)
  end

  def include_name?
    !object.anonymous_stance?
  end

  def include_author_id?
    !object.anonymous_stance?
  end

  def include_author?
    !object.anonymous_stance?
  end

  def include_record?
    !object.anonymous_stance?
  end
end

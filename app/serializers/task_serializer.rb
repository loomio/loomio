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

  has_one :record, polymorphic: true
  has_one :author, serializer: AuthorSerializer, root: :users
end

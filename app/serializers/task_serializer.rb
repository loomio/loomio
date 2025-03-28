class TaskSerializer < ApplicationSerializer
  attributes :id,
             :name,
             :author_id,
             :uid,
             :done,
             :done_at,
             :due_on,
             :record_type,
             :record_id,
             :hidden

  has_one :record, polymorphic: true, key: 'record_obj'
  has_one :author, serializer: AuthorSerializer, root: :users
  
  def hidden
    return nil unless scope[:current_user_id]

    extension = TasksUsersExtension.where(task_id: self.object.id, user_id: scope[:current_user_id]).take()
    if extension.nil?
      return false 
    else
      return extension.read_attribute(:hidden)
    end
  end
end

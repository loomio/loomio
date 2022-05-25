class DemoSerializer < ApplicationSerializer
  attributes :id,
             :name,
             :description,
             :group_id,
             :priority,
             :demo_handle


  has_one :author, serializer: AuthorSerializer, root: :users
  has_one :group
end

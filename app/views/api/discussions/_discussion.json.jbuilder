json.(discussion, :id, :title, :description, :created_at, :updated_at, :items_count, :comments_count)

json.author do
 json.partial! 'api/discussions/author', author: discussion.author
end

json.current_user do
 json.partial! 'api/discussions/author', author: current_user
end

json.events discussion.items, partial: 'api/discussions/item', as: :item

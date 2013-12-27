object @discussion

attributes :id,
           :title,
           :description,
           :created_at,
           :updated_at,
           :items_count,
           :comments_count

node :author do |discussion|
  partial 'api/discussions/author', object: discussion.author
end

node :events do |discussion|
  partial 'api/discussions/item', object: discussion.items
end

node :current_user do |discussion|
  partial 'api/discussions/author', object: current_user
end

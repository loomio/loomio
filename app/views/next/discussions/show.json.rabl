object false

child @discussion do
  attributes :id,
             :title,
             :description,
             :created_at,
             :updated_at,
             :items_count,
             :comments_count

  child :author => :author do
    attributes :name, :email, :id
  end

  child :item_ids_and_times do

  end
end

child @reader do
  attributes :last_read_at,
             :read_comments_count,
             :read_items_count
end

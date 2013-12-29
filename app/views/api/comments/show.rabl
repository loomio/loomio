object @comment

attributes :id,
           :body,
           :discussion_id,
           :created_at,
           :updated_at

node :author do |comment|
  partial 'api/discussions/author', object: comment.author
end

node :parent do |comment|
  attributes :id,
             :body,
             :discussion_id,
             :created_at,
             :updated_at

  node :author do |comment|
    partial 'api/discussions/author', object: comment.author
  end
end

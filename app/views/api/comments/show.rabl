object @comment

attributes :id,
           :body,
           :created_at,
           :updated_at

node :author do |comment|
  partial 'api/discussions/author', object: comment.author
end

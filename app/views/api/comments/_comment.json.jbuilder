json.(comment, :id, :body, :discussion_id, :created_at, :updated_at, :liker_ids_and_names)

json.author do
 json.partial! 'api/users/author', author: comment.author
end

if comment.parent.present?
  json.parent do
    json.partial! 'api/comments/comment', comment: comment.parent
  end
end

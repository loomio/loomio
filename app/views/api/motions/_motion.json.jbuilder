json.(motion, :id, :discussion_id, :name, :description, :created_at, :updated_at, :closing_at)

json.author do
 json.partial! 'api/discussions/author', author: motion.author
end

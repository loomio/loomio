#event
#
attributes :id, :sequence_id, :kind

child :eventable do |eventable|
  case eventable.class.to_s
  when "Comment"
    attributes :body, :created_at, :id, :liker_ids_and_names
    node :author do
      partial 'api/discussions/author', object: eventable.author
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
  when "Discussion"
  when "Motion"
  when "Vote"
  end
end

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
  when "Discussion"
  when "Motion"
  when "Vote"
  end
end

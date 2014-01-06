json.(discussion, :id, :title, :description, :created_at, :updated_at, :items_count, :comments_count)

json.author do
 json.partial! 'api/users/author', author: discussion.author
end

json.proposal do
  if discussion.current_proposal.present?
    json.partial! 'api/proposals/proposal', proposal: discussion.current_proposal
  else
    nil
  end
end

json.events discussion.items, partial: 'api/discussions/item', as: :item

# this is a hack until i get an AuthenticatorService going
json.current_user do
 json.partial! 'api/users/author', author: current_user
end

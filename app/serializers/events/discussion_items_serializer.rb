class Events::DiscussionItemsSerializer < ApplicationSerializer
  has_many :items, root: :events
end

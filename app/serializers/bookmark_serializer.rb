class BookmarkSerializer < ApplicationSerializer
  # Bookmarks are a flat, self-contained list — title and url are computed so
  # the client can render and link to the subject without loading the full
  # bookmarkable record.
  attributes :id, :bookmarkable_id, :bookmarkable_type, :user_id, :created_at, :discarded_at, :title, :url, :author_name, :poll_type
end

class BookmarkSerializer < ApplicationSerializer
  # Bookmarks are a flat, self-contained list — title and url are computed so
  # the client can render and link to the subject without loading the full
  # bookmarkable record.
  attributes :id, :bookmarkable_id, :bookmarkable_type, :user_id, :created_at, :discarded_at, :title, :url, :author_name, :poll_type

  def bookmarkable_id
    return object.bookmarkable_id unless anonymous_stance?

    Stance.anonymous_id_for(poll_id: object.bookmarkable.poll_id, stance_id: object.bookmarkable_id)
  end

  def url
    return object.url unless anonymous_stance?

    polymorphic_path(object.bookmarkable.poll)
  end

  private

  def anonymous_stance?
    object.bookmarkable_type == 'Stance' && object.bookmarkable&.poll&.anonymous?
  end
end

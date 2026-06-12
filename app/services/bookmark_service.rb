class BookmarkService
  def self.update(bookmark:, params:, actor:)
    actor.ability.authorize! :update, bookmark

    bookmark.user = actor
    bookmark.discarded_at = nil # re-bookmarking an item that was removed

    return false unless bookmark.valid?
    bookmark.save!

    MessageChannelService.publish_models([bookmark], user_id: actor.id)

    bookmark
  end

  # Removing a bookmark soft-discards it and broadcasts the discarded record, so
  # the user's open sessions drop it from their bookmark list and count. A nightly
  # task hard-deletes records discarded more than 24 hours ago.
  def self.destroy(bookmark:, actor:)
    actor.ability.authorize! :destroy, bookmark

    bookmark.discard

    MessageChannelService.publish_models([bookmark], user_id: actor.id)
  end
end

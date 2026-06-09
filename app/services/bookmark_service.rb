class BookmarkService
  def self.update(bookmark:, params:, actor:)
    actor.ability.authorize! :update, bookmark

    bookmark.user = actor

    return false unless bookmark.valid?
    bookmark.save!

    MessageChannelService.publish_models([bookmark], user_id: actor.id)

    bookmark
  end

  def self.destroy(bookmark:, actor:)
    actor.ability.authorize! :destroy, bookmark

    bookmark.destroy
  end
end

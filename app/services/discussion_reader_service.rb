class DiscussionReaderService

  def self.update(discussion_reader:, params:, actor:)
    actor.ability.authorize! :update, discussion_reader
    discussion_reader.update(starred: !!params[:starred]) &&
    discussion_reader.set_volume!(params[:volume])
  end

end

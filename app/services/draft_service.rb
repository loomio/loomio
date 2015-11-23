class DraftService

  def self.update(draft:, params:, actor:)
    actor.ability.authorize! :update, draft
    draft.update(payload: params[:payload], user: actor)
  end

end

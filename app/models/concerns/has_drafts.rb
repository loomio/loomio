module HasDrafts
  def perform_draft_purge!(user)
    purge_draft!(user)
  end

  def purge_draft!(user)
    return unless draft = user.drafts.find_by(draftable: draft_parent)
    field = is_a?(Group) ? 'group' : self.class.to_s.downcase
    draft.payload.except!(field)
    draft.tap(&:save)
  end

  def draft_parent
    raise NotImplementedError.new
  end
end

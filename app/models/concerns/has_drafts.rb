module HasDrafts
  def perform_draft_purge!(user)
    if purge_drafts_asynchronously?
      purge_draft!(user)
    else
      purge_draft_without_delay!(user)
    end
  end

  # override for models which cannot tolerate non-async draft deletion
  def purge_drafts_asynchronously?
    true
  end

  def purge_draft!(user)
    return unless draft = user.drafts.find_by(draftable: draft_parent)
    field = is_a?(FormalGroup) ? 'group' : self.class.to_s.downcase
    draft.payload.except!(field)
    draft.tap(&:save)
  end
  handle_asynchronously :purge_draft!

  def draft_parent
    raise NotImplementedError.new
  end
end

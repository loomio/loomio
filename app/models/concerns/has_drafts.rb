module HasDrafts
  def perform_draft_purge!
    if purge_drafts_asyncronously?
      purge_draft!
    else
      purge_draft_without_delay!
    end
  end

  # override for models which cannot tolerate non-async draft deletion
  def purge_drafts_asyncronously?
    true
  end

  def purge_draft!
    return unless draft = author.drafts.find_by(draftable: draft_parent)
    delete draft.payload[model.class.to_s.downcase]
    draft.tap(&:save)
  end
  handle_asynchronously :purge_draft!

  def draft_parent
    raise NotImplementedError.new
  end
end

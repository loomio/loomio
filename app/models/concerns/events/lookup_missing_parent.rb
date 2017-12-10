module Events::LookupMissingParent
  def self.lookup_parent(comment)
    if comment.first_ancestor
      first_ancestor.created_event
    else
      discussion.created_event
    end
  end
end

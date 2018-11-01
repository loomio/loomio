DiscussionTagCache = Struct.new(:discussions) do
  def data
    DiscussionTag.joins(:tag).where(discussion: discussions).group_by(&:discussion_id)
  end
end

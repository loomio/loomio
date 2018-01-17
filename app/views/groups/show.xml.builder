atom_feed do |feed|
  feed.title @group.name
  feed.subtitle @group.description
  feed.updated(@group.discussions.maximum(:created_at))

  @group.discussions.visible_to_public.each do |discussion|
    feed.entry(discussion) do |entry|
      entry.title     discussion.title
      entry.content   discussion.description, type: :text
      entry.link      discussion_url(discussion)
      entry.published discussion.created_at
      entry.author { |author| author.name discussion.author.name }
    end
  end
end if @group.is_visible_to_public?

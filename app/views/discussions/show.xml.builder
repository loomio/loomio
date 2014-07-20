atom_feed do |feed|
  feed.title @discussion.title
  feed.subtitle @discussion.description
  feed.updated(@activity.min_by(&:created_at).created_at) if @activity.any?
	
  @activity.each do |event|
    item = xml_item(event)
    feed.entry(event, url: discussion_url(@discussion)) do |entry|
      entry.title item.title
      entry.content item.body, type: :text
      entry.published item.created_at
      entry.author { |author| author.name item.author.name }
      entry.link discussion_url(@discussion)
    end
  end
end if @discussion.public?

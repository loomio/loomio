atom_feed do |feed|
  feed.title @discussion.title
  feed.subtitle @discussion.description
  feed.updated(@activity.min_by(&:created_at).created_at) if @activity.any?
	
  @activity.each do |event|
    item = xml_item(event)
    feed.entry(event, url: discussion_url(@discussion)) do |entry|
      # Item.author breaks! Do you want to fix it?
      # entry.title t(:comment_by, comment_author: item.author.name)
      entry.title "Error: http://goo.gl/eI3ykj"
      entry.content item.body, type: :text
      entry.published item.created_at
      # entry.author { |author| author.name item.author.name }
      entry.link discussion_url(@discussion)
    end
  end
end if @discussion.public?

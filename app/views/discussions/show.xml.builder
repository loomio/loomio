atom_feed do |feed|
  feed.title @discussion.title
  feed.subtitle @discussion.description
  feed.updated(@activity.min_by(&:created_at).created_at) if @activity.any?

  @activity.each do |event|
    next if event.eventable.nil?
    next unless event.eventable.valid?

    item = xml_item(event)
    next if item.nil?
    next if item.author.blank?
    feed.entry(event, url: discussion_url(@discussion)) do |entry|
      entry.title t(:comment_by, comment_author: item.author_name)
      entry.content item.body, type: :text
      entry.published item.created_at
      entry.author do |author|
        author.name item.author_name
        author.uri  user_url(item.author)
      end
      entry.link discussion_url(@discussion)
    end
  end
end if !@discussion.private

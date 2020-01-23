atom_feed do |feed|
  feed.title @discussion.title
  feed.subtitle @discussion.description
  feed.updated(@discussion.items.min_by(&:created_at).created_at) if @discussion.items.any?

  @discussion.items.each do |event|
    next if event.eventable.nil?
    next unless event.eventable.valid?

    item = event.eventable if event.kind.to_sym == :new_comment
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
      entry.link comment_url(key: event.eventable.discussion.key, comment_id: event.eventable.id)
    end
  end
end if LoggedOutUser.new.ability.can?(:show, @discussion)

atom_feed do |feed|
  feed.title @topic.topicable.title
  feed.subtitle @topic.topicable.description
  feed.updated(@topic.items.min_by(&:created_at).created_at) if @topic.items.any?

  @topic.items.each do |topic_item|
    next if topic_item.itemable.nil?
    next unless topic_item.itemable.valid?

    item = topic_item.itemable if topic_item.kind.to_sym == :new_comment
    next if item.nil?
    next if item.author.blank?
    feed.entry(topic_item, url: discussion_url(@topic.topicable)) do |entry|
      entry.title t(:'notifications.without_title.new_comment', actor: item.author_name)
      entry.content item.body, type: :text
      entry.published item.created_at
      entry.author do |author|
        author.name item.author_name
        author.uri  user_url(item.author)
      end
      entry.link comment_url(item)
    end
  end
end if LoggedOutUser.new.ability.can?(:show, @topic.topicable)

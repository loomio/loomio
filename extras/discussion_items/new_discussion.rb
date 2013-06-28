class DiscussionItems::NewDiscussion < DiscussionItem
  attr_reader :event, :discussion

  def initialize(event, discussion)
    @event, @discussion = event, discussion
    return self
  end

  def icon
    'discussion-icon'
  end

  def actor
    discussion.author
  end

  def header
    I18n.t('discussion_items.new_discussion') + ": "
  end

  def group
    discussion.group
  end

  def body
    " #{discussion.version_at(event.created_at).title}"
  end

  def time
    discussion.created_at
  end
end
class DiscussionItems::DiscussionTitleEdited < DiscussionItem
  attr_reader :event, :discussion

  def initialize(event, discussion)
    @event, @discussion = event, discussion
  end

  def icon
    'loomio-icon'
  end

  def actor
    event.user
  end

  def header
    I18n.t('discussion_items.discussion_title_edited') + ": "
  end

  def group
    discussion.group
  end

  def body
    " #{discussion.version_at(event.created_at).title}"
  end

  def time
    event.created_at
  end
end
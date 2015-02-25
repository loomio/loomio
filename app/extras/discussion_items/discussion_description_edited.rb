class DiscussionItems::DiscussionDescriptionEdited < DiscussionItem
  attr_reader :event, :discussion

  def initialize(event, discussion)
    @event, @discussion = event, discussion
  end

  def icon
    'discussion-icon'
  end

  def actor
    event.user
  end

  def header
    I18n.t('discussion_items.discussion_description_edited')
  end

  def group
    discussion.group
  end

  def body
    "<a href='/d/#{@discussion.key}/show_description_history' class='see-description-history' data-method='post' data-remote='true' rel='nofollow'>(#{I18n.t(:"discussion_context.see_history")})</a>".html_safe
  end

  def time
    event.created_at
  end
end
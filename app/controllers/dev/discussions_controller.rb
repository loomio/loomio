class Dev::DiscussionsController < Dev::BaseController
  include Dev::DiscussionsHelper
  skip_before_filter :cleanup_database

  def test_none_read
    discussion = create_discussion_with_nested_comments
    sign_in discussion.author
    redirect_to discussion_url(discussion)
  end

  def test_some_read
    discussion = create_discussion_with_nested_comments
    sign_in discussion.author
    event = discussion.items.order(id: :asc).first(5).last
    EventService.mark_as_read(event: event, actor: discussion.author)
    redirect_to discussion_url(discussion)
  end

  def test_most_read
    discussion = create_discussion_with_nested_comments
    sign_in discussion.author
    event = discussion.items.order(id: :asc).last(5).first
    EventService.mark_as_read(event: event, actor: discussion.author)
    redirect_to discussion_url(discussion)
  end

  def test_all_read
    discussion = create_discussion_with_nested_comments
    sign_in discussion.author
    event = discussion.items.order(id: :asc).last
    EventService.mark_as_read(event: event, actor: discussion.author)
    redirect_to discussion_url(discussion)
  end
end

class Dev::DiscussionsController < Dev::BaseController
  include Dev::DiscussionsHelper
  skip_before_action :cleanup_database

  def test_none_read
    discussion = create_discussion_with_nested_comments
    sign_in discussion.author
    redirect_to discussion_url(discussion)
  end

  def test_some_read
    discussion = create_discussion_with_nested_comments
    sign_in discussion.author
    read_ids = discussion.items.order(sequence_id: :asc).limit(5).pluck(:sequence_id)
    DiscussionReader.for_model(discussion, discussion.author).viewed!(read_ids)
    redirect_to discussion_url(discussion)
  end

  def test_most_read
    discussion = create_discussion_with_nested_comments
    sign_in discussion.author
    read_ids = discussion.items.order(sequence_id: :desc).limit(5).pluck(:sequence_id)
    DiscussionReader.for_model(discussion, discussion.author).viewed!(read_ids)
    redirect_to discussion_url(discussion)
  end

  def test_all_read
    discussion = create_discussion_with_nested_comments
    sign_in discussion.author
    read_ids = discussion.items.order(sequence_id: :asc).pluck(:sequence_id)
    DiscussionReader.for_model(discussion, discussion.author).viewed!(read_ids)
    redirect_to discussion_url(discussion)
  end

  def test_sampled_comments
    discussion = create_discussion_with_sampled_comments
    sign_in discussion.author
    redirect_to discussion_url(discussion)
  end
end

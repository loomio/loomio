class Dev::DiscussionsController < Dev::BaseController
  include Dev::FakeDataHelper

  def test_save_as_template
    group = create_group_with_members
    group.update!(members_can_create_templates: params[:members_can_create_templates].present?)
    admin = group.admins.first
    discussion = DiscussionService.create(params: {
      group_id: group.id, title: 'Monthly project review',
      description: '<p>What worked, and what should change next month?</p>', description_format: 'html',
      tags: ['Project review'], allow_concurrent_polls: true, comment_length_max: 400
    }, actor: admin)
    CommentService.create(comment: Comment.new(parent: discussion, body: 'Private review feedback'), actor: admin)
    actor = params[:member].present? ? group.members.where.not(id: admin.id).first : admin
    sign_in actor
    redirect_to discussion_url(discussion)
  end

  def test_none_read
    discussion = create_discussion_with_nested_comments
    sign_in discussion.author
    redirect_to discussion_url(discussion)
  end

  def test_some_read
    discussion = create_discussion_with_nested_comments
    TopicService.repair(discussion.topic_id)
    discussion.author.experienced!('betaFeatures')
    sign_in discussion.author
    topic = discussion.topic
    read_ids = topic.items.order(sequence_id: :asc).limit(5).pluck(:sequence_id)
    TopicReader.for(topic: topic, user: discussion.author).viewed!(read_ids)
    redirect_to discussion_url(discussion)
  end

  def test_most_read
    discussion = create_discussion_with_nested_comments
    sign_in discussion.author
    read_ids = discussion.topic.items.order(sequence_id: :asc).limit(5).pluck(:sequence_id)
    TopicReader.for(topic: discussion.topic, user: discussion.author).viewed!(read_ids)
    redirect_to discussion_url(discussion)
  end

  def test_all_read
    discussion = create_discussion_with_nested_comments
    sign_in discussion.author
    read_ids = discussion.topic.items.order(sequence_id: :asc).pluck(:sequence_id)
    TopicReader.for(topic: discussion, user: discussion.author).viewed!(read_ids)
    redirect_to discussion_url(discussion)
  end

  def test_sampled_comments
    discussion = create_discussion_with_sampled_comments
    sign_in discussion.author
    redirect_to discussion_url(discussion)
  end
end

class Dev::DiscussionsController < Dev::BaseController
  include Dev::FakeDataHelper

  def test_save_as_template
    group = create_group_with_members
    group.update!(members_can_create_templates: params[:members_can_create_templates].present?)
    admin = group.admins.first
    discussion = DiscussionService.create(params: {
      group_id: group.id, title: 'Monthly project review',
      description: '<p>What worked, and what should change next month?</p>', description_format: 'html',
      tags: ['Project review'], polls_one_at_a_time: false, comment_length_max: 400
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

  def test_long_content
    group = create_group_with_members
    reader = group.admins.first
    author = group.members.where.not(id: reader.id).first
    paragraph = '<p>We need enough context to understand how the delivery schedule affects our members. The morning route gives the warehouse team time to prepare orders, while the afternoon route makes it easier for volunteers to help.</p>'
    discussion = DiscussionService.create(params: {
      group_id: group.id, title: 'Planning our next delivery',
      description: '<p>Long read context</p>' + paragraph * 12,
      description_format: 'html'
    }, actor: reader)
    parent = CommentService.create(comment: Comment.new(parent: discussion,
      body: '<p>Long read parent</p>' + paragraph * 12 + '<p><a href="https://example.com/delivery">Delivery details</a></p>',
      body_format: 'html'), actor: author)
    CommentService.create(comment: Comment.new(parent: parent,
      body: '<p>Unread reply: could we try the morning route next week?</p>', body_format: 'html'), actor: author)
    short = CommentService.create(comment: Comment.new(parent: discussion,
      body: '<p>Short read comment</p>', body_format: 'html'), actor: author)
    moderate = CommentService.create(comment: Comment.new(parent: discussion,
      body: '<p>Moderately long read comment</p>' + '<p>A delivery note.</p>' * 9, body_format: 'html'), actor: author)
    CommentService.create(comment: Comment.new(parent: discussion,
      body: '<p>Long unread comment</p>' + paragraph * 12, body_format: 'html'), actor: author)
    topic = discussion.topic.reload
    read_ids = [0, parent.created_topic_item.sequence_id, short.created_topic_item.sequence_id, moderate.created_topic_item.sequence_id]
    read_ids = topic.items.pluck(:sequence_id) if params[:all_read].present?
    TopicReader.for(topic: topic, user: reader).viewed!(read_ids)
    sign_in reader
    destination = params[:focus].present? ? discussion_url(discussion, comment_id: parent.id) : discussion_url(discussion)
    redirect_to destination
  end
end

require 'test_helper'

class TopicItemServiceTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @member = users(:user)
    @group = groups(:group)
    @source = create_discussion(group: @group, actor: @admin, title: 'Source')
    @target = create_discussion(group: @group, actor: @admin, title: 'Target')

    comment = Comment.new(parent: @source, body: 'Move me', author: @member)
    CommentService.create(comment: comment, actor: @member) do |topic_item|
      @topic_item = topic_item
    end
  end

  test 'topic admin can move items between administered topics' do
    enqueued_args = nil

    MoveCommentsWorker.stub(:perform_later, ->(*args) { enqueued_args = args }) do
      TopicItemService.move_comments(topic: @target.topic, actor: @admin, params: move_params)
    end

    assert_equal [[@topic_item.id], @source.topic_id, @target.topic_id, @admin.id], enqueued_args
  end

  test 'item author cannot move items without administering the source topic' do
    assert_raises CanCan::AccessDenied do
      TopicItemService.move_comments(topic: @target.topic, actor: @member, params: move_params)
    end
  end

  test 'source topic admin cannot move items into a topic they do not administer' do
    alien_target = create_discussion(group: groups(:alien_group), actor: users(:alien), title: 'Alien target')

    assert_raises CanCan::AccessDenied do
      TopicItemService.move_comments(topic: alien_target.topic, actor: @admin, params: move_params)
    end
  end

  test 'topic admin can move items across groups when they administer both topics' do
    alien_group = groups(:alien_group)
    Membership.create!(group: alien_group, user: @admin, admin: true, accepted_at: Time.current)
    alien_target = create_discussion(group: alien_group, actor: @admin, title: 'Administered alien target')
    enqueued_args = nil

    MoveCommentsWorker.stub(:perform_later, ->(*args) { enqueued_args = args }) do
      TopicItemService.move_comments(topic: alien_target.topic, actor: @admin, params: move_params)
    end

    assert_equal [[@topic_item.id], @source.topic_id, alien_target.topic_id, @admin.id], enqueued_args
  end

  private

  def create_discussion(group:, actor:, title:)
    DiscussionService.create(
      params: {title: "#{title} #{SecureRandom.hex(4)}", group_id: group.id},
      actor: actor
    )
  end

  def move_params
    {selected_topic_item_ids: [@topic_item.id]}
  end
end

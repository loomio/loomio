require 'test_helper'

class ReactionServiceTest < ActiveSupport::TestCase
  inline_jobs "comment reaction notification url uses contextual topic route"
  setup do
    @user = users(:user)
    @admin = users(:admin)
    @group = groups(:group)
    @discussion = discussions(:discussion)
    @comment = Comment.create(
      parent: @discussion,
      author: @user,
      body: "test comment"
    )

    @reaction = Reaction.new(
      reaction: "❤️",
      reactable: @comment,
      user: @user
    )
  end

  test "creates a reaction for the current user on a comment" do
    assert_difference 'Reaction.count', 1 do
      ReactionService.update(reaction: @reaction, params: { reaction: 'smiley' }, actor: @user)
    end
  end

  test "publishes the reaction directly without creating an topic_item" do
    publications = []

    MessageChannelService.stub(:publish_models, ->(models, **options) { publications << [ models, options ] }) do
      assert_no_difference -> { TopicItem.where(kind: "reaction_created").count } do
        assert_equal @reaction, ReactionService.update(
          reaction: @reaction,
          params: { reaction: "smiley" },
          actor: @user
        )
      end
    end

    assert publications.any? { |models, options| models == [ @reaction ] && options[:group_id] == @group.id }
  end

  test "rolls back reaction creation when notification creation fails" do
    assert_raises RuntimeError do
      NotificationService.stub(:create!, ->(**) { raise "notification failed" }) do
        ReactionService.update(reaction: @reaction, params: { reaction: 'smiley' }, actor: @user)
      end
    end

    assert_not Reaction.exists?(reactable: @comment, user: @user)
  end

  test "does not notify if the user is no longer in the group" do
    @group.memberships.find_by(user: @user).destroy

    reactor_reaction = Reaction.new(reaction: "❤️", reactable: @comment, user: @admin)
    ReactionService.update(reaction: reactor_reaction, params: { reaction: '😃' }, actor: @admin)
    notification = Notification.find_by!(
      kind: "reaction_created",
      subject: reactor_reaction
    )
    RouteNotificationDeliveriesWorker.perform_now(notification.id)

    assert_empty notification.notification_deliveries
  end

  test "comment reaction notification url uses contextual topic route" do
    reactor_reaction = Reaction.new(reaction: "❤️", reactable: @comment, user: @admin)
    assert_no_difference -> { TopicItem.where(kind: "reaction_created").count } do
      ReactionService.update(reaction: reactor_reaction, params: { reaction: '😃' }, actor: @admin)
    end
    notification = Notification.find_by!(
      kind: "reaction_created",
      subject: reactor_reaction
    )

    assert_equal [ @user.id ], notification.notification_deliveries.where(channel: "in_app").pluck(:recipient_id)
    assert_equal 1, Notification.where(subject: reactor_reaction).count
    assert_equal "/d/#{@discussion.key}?comment_id=#{@comment.id}", notification.notification_url
  end

  test "removes a reaction for the current user on a comment" do
    @reaction.save

    assert_difference 'Reaction.count', -1 do
      ReactionService.destroy(reaction: @reaction, actor: @user)
    end
  end

  test "does not allow others to destroy a reaction" do
    @reaction.save

    outsider = User.create!(
      name: 'Outsider',
      email: "outsider#{SecureRandom.hex(4)}@example.com",
      email_verified: true,
      username: "outsider#{SecureRandom.hex(4)}"
    )

    assert_raises CanCan::AccessDenied do
      ReactionService.destroy(reaction: @reaction, actor: outsider)
    end
  end
end

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
      ReactionService.update(reaction: @reaction, params: { reaction: '😃' }, actor: @user)
    end
  end

  test "does not save a reaction longer than the supported emoji sequence" do
    assert_no_difference [ -> { Reaction.count }, -> { Notification.count } ] do
      ReactionService.update(
        reaction: @reaction,
        params: { reaction: "x" * (Reaction::REACTION_LENGTH_MAX + 1) },
        actor: @user
      )
    end

    assert_predicate @reaction, :invalid?
    assert_includes @reaction.errors[:reaction], "is too long (maximum is #{Reaction::REACTION_LENGTH_MAX} characters)"
  end

  test "accepts a multi-codepoint emoji from the reaction picker" do
    emoji = "🧑🏻‍❤️‍💋‍🧑🏼"

    assert_operator emoji.length, :>, 8
    assert_difference 'Reaction.count', 1 do
      ReactionService.update(reaction: @reaction, params: { reaction: emoji }, actor: @user)
    end
  end

  test "publishes the reaction directly without creating an topic_item" do
    publications = []

    MessageChannelService.stub(:publish_models, ->(models, **options) { publications << [ models, options ] }) do
      assert_no_difference -> { TopicItem.where(kind: "reaction_created").count } do
        assert_equal @reaction, ReactionService.update(
          reaction: @reaction,
          params: { reaction: "😃" },
          actor: @user
        )
      end
    end

    assert publications.any? { |models, options| models == [ @reaction ] && options[:group_id] == @group.id }
  end

  test "rolls back reaction creation when notification creation fails" do
    assert_raises RuntimeError do
      NotificationService.stub(:create!, ->(**) { raise "notification failed" }) do
        ReactionService.update(reaction: @reaction, params: { reaction: '😃' }, actor: @user)
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

  test "rapid reaction changes update one notification and its localized delivery" do
    @user.update!(selected_locale: "fr")
    reaction, notification = create_notified_reaction
    delivery = notification.notification_deliveries.find_by!(channel: "in_app", recipient: @user)
    original_values = delivery.translation_values.except("reaction")
    original_time = notification.created_at
    publications = []

    MessageChannelService.stub(:publish_models, ->(models, **options) { publications << [ models, options ] }) do
      assert_no_difference [ -> { Notification.count }, -> { NotificationDelivery.count } ] do
        travel 1.minute do
          ReactionService.update(reaction: reaction, params: { reaction: "👍" }, actor: @admin)
          ReactionService.update(reaction: reaction, params: { reaction: "😃" }, actor: @admin)
        end
      end
    end

    assert_equal "😃", notification.reload.translation_values["reaction"]
    assert_equal "😃", delivery.reload.translation_values["reaction"]
    assert_equal original_values, delivery.translation_values.except("reaction")
    assert_equal original_time, notification.created_at
    assert_not delivery.viewed?
    assert publications.any? { |models, options| models == [ notification ] && options[:user_id] == @user.id }
    serialized = NotificationSerializer.new(notification, scope: { current_user_id: @user.id }).as_json.fetch(:notification)
    assert_equal "😃", serialized[:reaction]

    digest = DigestQuery.new(user: @user, time_start: 1.day.ago, time_finish: 2.minutes.from_now)
    reactions = digest.notifications.select { |item| item.kind == "reaction_created" }
    assert_equal [ notification.id ], reactions.map(&:id)
    assert_equal "😃", reactions.first.translation_values_for(@user.id)["reaction"]
    @user.update!(email_catch_up_day: 7)
    mail = DigestMailer.digest(@user.id).deliver_now
    document = Nokogiri::HTML(mail.html_part.body.decoded)
    headings = document.css(".email-notification-text").select { |heading| heading.text.include?("😃") }
    assert_equal 1, headings.size
    assert_not document.css(".email-notification-text").any? { |heading| heading.text.include?("❤️") || heading.text.include?("👍") }
  end

  test "changing a reaction preserves an already read notification" do
    reaction, notification = create_notified_reaction
    delivery = notification.notification_deliveries.find_by!(channel: "in_app", recipient: @user)
    delivery.update!(viewed_at: Time.current)
    viewed_at = delivery.viewed_at

    assert_no_difference -> { Notification.count } do
      ReactionService.update(reaction: reaction, params: { reaction: "👍" }, actor: @admin)
    end

    assert_equal viewed_at, delivery.reload.viewed_at
    assert_equal "👍", delivery.translation_values["reaction"]
  end

  test "reaction changes after two minutes create a new notification" do
    reaction, notification = create_notified_reaction

    travel 2.minutes + 1.second do
      assert_difference -> { Notification.count }, 1 do
        ReactionService.update(reaction: reaction, params: { reaction: "👍" }, actor: @admin)
      end
    end

    assert_equal "❤️", notification.reload.translation_values["reaction"]
    assert_equal "👍", reaction.notifications.order(:id).last.translation_values["reaction"]
  end

  test "rapid changes remain separate for different people and comments" do
    first, notification_first = create_notified_reaction
    second, notification_second = create_notified_reaction(actor: users(:member_normal))
    other_comment = Comment.create!(parent: @discussion, author: @user, body: "another comment")
    third, notification_third = create_notified_reaction(reactable: other_comment)

    assert_no_difference -> { Notification.count } do
      [ [ first, @admin ], [ second, users(:member_normal) ], [ third, @admin ] ].each do |reaction, actor|
        ReactionService.update(reaction: reaction, params: { reaction: "👍" }, actor: actor)
      end
    end

    assert_equal 3, [ notification_first, notification_second, notification_third ].map(&:id).uniq.size
    [ notification_first, notification_second, notification_third ].each do |notification|
      assert_equal "👍", notification.reload.translation_values["reaction"]
    end
  end

  test "routing queued before a rapid change snapshots the latest reaction" do
    reaction = Reaction.new(reactable: @comment, user: @admin, reaction: "❤️")
    ReactionService.update(reaction: reaction, params: { reaction: "❤️" }, actor: @admin)
    notification = reaction.notifications.first
    router = NotificationDeliveryRouter.for(notification)
    assert_equal "❤️", router.subject_model.reaction

    assert_no_difference -> { Notification.count } do
      ReactionService.update(reaction: reaction, params: { reaction: "👍" }, actor: @admin)
    end
    router.route!

    delivery = notification.notification_deliveries.find_by!(channel: "in_app", recipient: @user)
    assert_equal "👍", delivery.translation_values["reaction"]
  end

  test "failed notification refresh rolls back the reaction and publishes no changes" do
    reaction, notification = create_notified_reaction
    publications = []

    MessageChannelService.stub(:publish_models, ->(*args, **options) { publications << [ args, options ] }) do
      assert_raises RuntimeError do
        ReactionService.stub(:publish_notification, ->(*) { flunk "published a rolled back notification" }) do
          NotificationDelivery.stub(:_update_record, ->(*) { raise "delivery refresh failed" }) do
            ReactionService.update(reaction: reaction, params: { reaction: "👍" }, actor: @admin)
          end
        end
      end
    end

    assert_equal "❤️", reaction.reload.reaction
    assert_equal "❤️", notification.reload.translation_values["reaction"]
    assert_empty publications
  end

  test "refresh does not publish a notification after its recipient loses access" do
    @comment.update!(author: users(:member_normal))
    reaction, notification = create_notified_reaction
    memberships(:member_normal_membership).update!(revoked_at: Time.current)
    publications = []

    MessageChannelService.stub(:publish_models, ->(models, **options) { publications << [ models, options ] }) do
      ReactionService.update(reaction: reaction, params: { reaction: "👍" }, actor: @admin)
    end

    assert_not publications.any? { |models, _| models.include?(notification) }
  end

  test "an outer rollback publishes neither the reaction nor its updated notification" do
    reaction, notification = create_notified_reaction
    publications = []
    events = []

    MessageChannelService.stub(:publish_models, ->(*args, **options) { publications << [ args, options ] }) do
      EventBus.stub(:broadcast, ->(*args) { events << args }) do
        Reaction.transaction(requires_new: true) do
          ReactionService.update(reaction: reaction, params: { reaction: "👍" }, actor: @admin)
          raise ActiveRecord::Rollback
        end
      end
    end

    assert_equal "❤️", reaction.reload.reaction
    assert_equal "❤️", notification.reload.translation_values["reaction"]
    assert_empty publications
    assert_empty events
  end

  test "rapid changes on a direct topic preserve its existing recipient rules" do
    comment = Comment.create!(parent: topics(:direct_topic).topicable, author: users(:guest_normal), body: "direct comment")
    reaction, notification = create_notified_reaction(reactable: comment, actor: users(:guest_loud))

    assert_no_difference [ -> { Notification.count }, -> { NotificationDelivery.count } ] do
      ReactionService.update(reaction: reaction, params: { reaction: "👍" }, actor: users(:guest_loud))
    end

    assert_equal "👍", notification.reload.translation_values["reaction"]
    assert_empty notification.notification_deliveries
  end

  test "revoked members cannot update an existing reaction notification" do
    actor = users(:member_normal)
    reaction, notification = create_notified_reaction(actor: actor)
    memberships(:member_normal_membership).update!(revoked_at: Time.current)
    actor = User.find(actor.id)

    assert_raises CanCan::AccessDenied do
      ReactionService.update(reaction: reaction, params: { reaction: "👍" }, actor: actor)
    end

    assert_equal "❤️", reaction.reload.reaction
    assert_equal "❤️", notification.reload.translation_values["reaction"]
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

  private

  def create_notified_reaction(reactable: @comment, actor: @admin)
    reaction = Reaction.new(reactable: reactable, user: actor, reaction: "❤️")
    ReactionService.update(reaction: reaction, params: { reaction: "❤️" }, actor: actor)
    notification = reaction.notifications.first
    RouteNotificationDeliveriesWorker.perform_now(notification.id)
    [ reaction, notification ]
  end
end

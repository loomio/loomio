require 'test_helper'

class PollEditGuestAccessTest < ActiveSupport::TestCase
  setup do
    @actor = users(:admin)
    @topic = topics(:discussion_topic)
    @poll = create_poll(@topic, @actor)
    clear_enqueued_jobs
  end

  test 'notify grants an external email guest access only to the poll topic' do
    email = 'poll-notify-external@example.test'
    PollService.update(poll: @poll, actor: @actor, params: { recipient_emails: [email] })
    guest = User.find_by!(email: email)
    reader = TopicReader.active.find_by!(topic: @topic, user: guest)
    assert reader.guest?
    assert_not reader.admin?
    assert_equal @actor.id, reader.inviter_id
    assert guest.can?(:show, @poll)
    assert_not guest.can?(:show, topics(:alien_discussion_topic))
    assert_not Membership.active.exists?(user: guest)
    assert_not guest.can?(:vote_in, @poll)
    notification = Notification.about(@poll).find_by!(kind: 'poll_edited')
    RouteNotificationDeliveriesWorker.perform_now(notification.id)
    assert_equal %w[email in_app], notification.notification_deliveries.order(:channel).pluck(:channel)
    assert_empty ActionMailer::Base.deliveries
  end

  test 'poll editor without guest invitation permission cannot create a recipient or grant access' do
    actor = users(:guest_admin_normal)
    assert actor.can?(:update, @poll)
    assert_not actor.can?(:add_guests, @topic)
    assert_no_difference ['User.count', 'TopicReader.count', 'Notification.count'] do
      assert_raises CanCan::AccessDenied do
        PollService.update(poll: @poll, actor: actor, params: { recipient_emails: ['unauthorized@example.test'] })
      end
    end
  end

  test 'non editor cannot grant access by notifying a guest' do
    assert_no_difference ['User.count', 'TopicReader.count', 'Notification.count'] do
      assert_raises CanCan::AccessDenied do
        PollService.update(poll: @poll, actor: users(:alien), params: { recipient_emails: ['alien-invite@example.test'] })
      end
    end
  end

  test 'notification failure rolls back poll edit guest account and topic access' do
    before_title = @poll.title
    assert_no_difference ['User.count', 'TopicReader.count', 'Notification.count', 'TopicItem.count'] do
      assert_raises RuntimeError do
        NotificationService.stub(:create!, ->(**) { raise 'notification failed' }) do
          PollService.update(poll: @poll, actor: @actor, params: {
            title: 'Rolled back title', recipient_message: 'Rolled back note',
            recipient_emails: ['rollback-guest@example.test']
          })
        end
      end
    end
    assert_equal before_title, @poll.reload.title
    assert_no_enqueued_jobs only: RouteNotificationDeliveriesWorker
    assert_no_enqueued_jobs only: PublishLiveUpdateTopicItemWorker
  end

  test 'reinvited guest retains volume settings and revoked access stops queued delivery' do
    guest = users(:former_guest_loud)
    reader = topic_readers(:former_guest_loud_reader)
    PollService.update(poll: @poll, actor: @actor, params: { recipient_emails: [guest.email] })
    assert_nil reader.reload.revoked_at
    assert_equal 'loud', reader.volume_email
    assert guest.can?(:show, @poll)
    notification = Notification.about(@poll).find_by!(kind: 'poll_edited')
    reader.update!(revoked_at: Time.current, revoker_id: @actor.id)
    RouteNotificationDeliveriesWorker.perform_now(notification.id)
    assert_empty notification.notification_deliveries
  end

  test 'embedded poll voter audience stays scoped to the poll' do
    recipient = users(:guest_normal)
    PollService.invite(poll: @poll, actor: @actor, params: { recipient_user_ids: [recipient.id] })
    PollService.update(poll: @poll, actor: @actor, params: { recipient_audience: 'voters' })
    notification = Notification.about(@poll).find_by!(kind: 'poll_edited')
    assert_equal [recipient.id], notification.recipient_user_ids
    assert_not_includes notification.recipient_user_ids, users(:guest_loud).id
  end

  test 'permission to notify a parent group does not authorize adding guests to a subgroup topic' do
    topic = topics(:subgroup_discussion_topic)
    actor = users(:user)
    groups(:group).update!(members_can_announce: true)
    groups(:subgroup).update!(members_can_add_guests: false)
    poll = create_poll(topic, actor)
    assert actor.can?(:update, poll)
    assert actor.can?(:notify, groups(:group))
    assert_not actor.can?(:add_guests, topic)
    assert_no_difference ['TopicReader.count', 'Notification.count'] do
      assert_raises CanCan::AccessDenied do
        PollService.update(poll: poll, actor: actor, params: { recipient_audience: "group-#{groups(:group).id}" })
      end
    end
    assert_not topic.members.exists?(users(:member_normal).id)
  end

  test 'direct poll guest invitation uses topic access without group membership' do
    topic = topics(:direct_topic)
    actor = users(:guest_admin_normal)
    poll = create_poll(topic, actor)
    email = 'direct-poll-notify@example.test'
    PollService.update(poll: poll, actor: actor, params: { recipient_emails: [email] })
    guest = User.find_by!(email: email)
    assert topic.members.exists?(guest.id)
    assert guest.can?(:show, poll)
    assert_not Membership.exists?(user: guest)
    notification = Notification.about(poll).find_by!(kind: 'poll_edited')
    RouteNotificationDeliveriesWorker.perform_now(notification.id)
    assert_equal %w[email in_app], notification.notification_deliveries.order(:channel).pluck(:channel)
  end

  test 'anonymous poll notify grants topic access without adding a voter or ballot' do
    @topic.update!(allow_concurrent_polls: true)
    poll = create_poll(@topic, @actor, anonymous: true)
    before_voters = poll.anonymous_poll_voters.count
    email = 'anonymous-poll-notify@example.test'
    PollService.update(poll: poll, actor: @actor, params: { recipient_message: 'Updated anonymous poll', recipient_emails: [email] })
    guest = User.find_by!(email: email)
    assert guest.can?(:show, poll)
    assert_not guest.can?(:vote_in, poll)
    assert_not guest.can?(:view_anonymous_voters, poll)
    assert_equal before_voters, poll.anonymous_poll_voters.count
    assert_not Stance.exists?(poll: poll, participant: guest)
    notification = Notification.about(poll).find_by!(kind: 'poll_edited')
    RouteNotificationDeliveriesWorker.perform_now(notification.id)
    assert_equal %w[email in_app], notification.notification_deliveries.order(:channel).pluck(:channel)
    data = MessageChannelService.serialize_models([notification.subject], scope: {current_user: guest, current_user_id: guest.id})
    record = JSON.parse(data.to_json).fetch('topic_items').find { |item| item['id'] == notification.subject_id }
    assert_equal 'Updated anonymous poll', record.fetch('change_note')
    assert_not record.key?('recipient_user_ids')
  end

  private

  def create_poll(topic, actor, **attributes)
    PollService.create(params: {
      topic_id: topic.id, title: 'Guest access regression', poll_type: 'proposal',
      poll_option_names: %w[agree disagree], closing_at: 3.days.from_now,
      notify_on_open: false, specified_voters_only: true
    }.merge(attributes), actor: actor)
  end
end

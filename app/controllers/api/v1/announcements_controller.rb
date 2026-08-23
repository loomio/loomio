class Api::V1::AnnouncementsController < Api::V1::RestfulController
  before_action :require_current_user

  def available_audiences
    current_user.ability.authorize! :members_autocomplete, recipient_target

    render json: {
      audiences: NotificationAudienceService.available(
        model: target_model,
        actor: current_user,
        include_actor: params[:include_actor].present?
      )
    }, root: false
  end

  def audience
    current_user.ability.authorize! :members_autocomplete, recipient_target

    self.collection = NotificationAudienceService.resolve(
      model: target_model,
      kind: params[:recipient_audience],
      actor: current_user,
      exclude_members: params[:exclude_members],
      include_actor: params[:include_actor].present?
    )
    respond_with_collection
  end

  def new_member_count
    current_user.ability.authorize! :add_members, target_model

    count = UserInviter.new_members_count(
      parent_group: target_model.parent_or_self,
      user_ids: String(params[:recipient_user_xids]).split('x').map(&:to_i),
      emails: String(params[:recipient_emails_cmr]).split(',')
    )
    render json: {count: count}
  end

  # count for number of notifications that will be send
  def count
    model = target_model
    UserInviter.authorize_preview!(
      actor: current_user,
      model: model,
      emails: String(params[:recipient_emails_cmr]).split(','),
      audience: params[:recipient_audience]
    )

    count = UserInviter.count(
      actor: current_user,
      model: model,
      emails: String(params[:recipient_emails_cmr]).split(','),
      user_ids: String(params[:recipient_user_xids]).split('x').map(&:to_i),
      chatbot_ids: String(params[:recipient_chatbot_xids]).split('x').map(&:to_i),
      audience: params[:recipient_audience],
      exclude_members: params[:exclude_members].present?,
      include_actor: params[:include_actor].present?
    )
    render json: {count: count}
  end

  def search
    model = target_model
    UserInviter.authorize_recipient_discovery!(model: model, actor: current_user)

    # if target model has no groups, no discussions, then draw from users groups and guest threads
    self.collection = if params[:existing_only]
      model.members.invitable_search(params[:q]).limit(50)
    else
      UserQuery.invitable_search(
        model: model,
        actor: current_user,
        q: params[:q]
      )
    end
    respond_with_collection serializer: AuthorSerializer, root: :users
  end

  def create
    if target_model.is_a?(Group)
      self.collection = GroupService.invite(group: target_model, actor: current_user, params: params)
      respond_with_collection serializer: MembershipSerializer, root: :memberships
    elsif target_model.is_a?(Topic)
      notification = TopicService.invite(topic: target_model, actor: current_user, params: params)
      self.collection = TopicReader.where(topic_id: target_model.id, user_id: notification.recipient_user_ids)
      respond_with_collection serializer: TopicReaderSerializer, root: :topic_readers
    elsif target_model.is_a?(Poll)
      self.collection = PollService.invite(poll: target_model, actor: current_user, params: params)
      if target_model.detached_anonymous?
        self.collection = User.where(id: collection.select(:voter_id))
        respond_with_collection serializer: AuthorSerializer, root: :users
      else
        respond_with_collection serializer: StanceSerializer, root: :stances
      end
    elsif target_model.is_a?(Outcome)
      self.collection = OutcomeService.invite(outcome: target_model, actor: current_user, params: params)
      respond_with_collection serializer: UserSerializer, root: :users
    end
  end

  def users_notified_count
    # returns a count of users notified about this thing
    current_user.ability.authorize! :show, target_model

    notifications = target_notification_scope
    user_ids = NotificationDelivery.where(
      notification_id: notifications.select(:id),
      recipient_type: "User",
      channel: "in_app"
    ).distinct.pluck(:recipient_id)

    render json: { count: user_ids.uniq.count }
  end

  def history
    authorize_history!

    allow_viewed = true

    if target_model.respond_to?(:topic) &&
       target_model.topic.present? &&
       Poll.joins(:topic).where(topics: { id: target_model.topic_id }).kept.where(anonymous: true).any?
      allow_viewed = false
    end

    if target_model.respond_to?(:poll) &&
       target_model.poll.present? &&
       target_model.poll.anonymous?
      allow_viewed = false
    end

    scoped_notifications = target_notification_scope
      .includes(:notification_deliveries)
      .order(id: :desc)
      .limit(1000)

    # A notification is one occurrence. Its in-app deliveries contain the
    # recipient-specific history state.
    res = scoped_notifications.filter_map do |notification|
      recipient_states = history_recipient_states(notification, allow_viewed: allow_viewed)
      next if recipient_states.empty?

      {
        id: "notification_#{notification.id}",
        created_at: notification.created_at,
        author_id: notification.actor_id,
        kind: notification.kind,
        notifications: recipient_states
      }
    end
    res.sort_by! { |entry| entry[:created_at] }.reverse!

    user_ids = res.flat_map { |e| [e[:author_id]] + e[:notifications].map { |n| n[:user_id] } }.uniq.compact
    users = User.where(id: user_ids).map { |u| AuthorSerializer.new(u).as_json(root: false) }
    render root: false, json: {allow_viewed: allow_viewed, data: res, users: users}
  end

  private

  def target_notification_scope
    scope = Notification.where(kind: notification_kinds)

    scope = if target_model.is_a?(Topic)
      discussion_ids = target_model.topicable_type == "Discussion" ? [ target_model.topicable_id ] : []
      poll_ids = Poll.where(topic_id: target_model.id).pluck(:id)
      outcome_ids = Outcome.where(poll_id: poll_ids).pluck(:id)
      comment_ids = TopicItem.where(topic_id: target_model.id, itemable_type: "Comment").pluck(:itemable_id)
      scope.where(<<~SQL.squish, d: discussion_ids, p: poll_ids, o: outcome_ids, c: comment_ids)
        (subject_type = 'Discussion' AND subject_id IN (:d)) OR
        (subject_type = 'Poll'       AND subject_id IN (:p)) OR
        (subject_type = 'Outcome'    AND subject_id IN (:o)) OR
        (subject_type = 'Comment'    AND subject_id IN (:c))
      SQL
    else
      scope.where(subject: target_model)
    end

    # Recipient identities for an anonymous poll's derived closing reminder
    # reveal participation or non-participation. Do not expose that composition
    # through announcement history or its recipient count, even without viewed
    # state. Explicit poll announcements and reminders remain visible.
    anonymous_poll_ids = case target_model
    when Topic
      Poll.where(topic_id: target_model.id, anonymous: true).pluck(:id)
    when Poll
      target_model.anonymous? ? [ target_model.id ] : []
    when Outcome
      target_model.poll&.anonymous? ? [ target_model.poll_id ] : []
    else
      []
    end
    return scope if anonymous_poll_ids.empty?

    scope.where.not(
      kind: "poll_closing_soon",
      subject_type: "Poll",
      subject_id: anonymous_poll_ids
    )
  end

  def history_recipient_states(notification, allow_viewed:)
    states = notification.notification_deliveries.filter_map do |delivery|
      next unless delivery.channel == "in_app" && delivery.recipient_type == "User"

      { id: notification.id, user_id: delivery.recipient_id, viewed: delivery.viewed? }
    end
    states.map { |state| state.merge(viewed: allow_viewed && state[:viewed]) }
  end

  def notification_kinds
    %w[announcement_created
       user_mentioned
       group_mentioned
       announcement_resend
       discussion_announced
       poll_announced
       outcome_announced
       outcome_created
       outcome_updated
       outcome_edited
       poll_created
       poll_edited
       poll_reminder
       new_discussion
       discussion_edited
       comment_replied_to
       poll_closing_soon]
  end

  def authorize_history!
    model = target_model

    allowed = case model
    when Group
      model.members.exists?(current_user.id)
    when Topic
      model.members.exists?(current_user.id)
    when Discussion, Comment, Poll, Outcome
      model.topic&.members&.exists?(current_user.id)
    else
      false
    end

    raise CanCan::AccessDenied unless allowed
  end

  def default_scope
    is_admin = if target_model && target_model.respond_to?(:group_id)
                 if target_model.group_id
                   target_model.group.admins.exists?(current_user.id)
                 elsif target_model.respond_to?(:admins)
                   target_model.admins.exists?(current_user.id)
                 else
                   false
                 end
               else
                 false
               end

    super.merge(
      include_email: is_admin
    )
  end

  def authorize_model
    load_and_authorize(:group, :announce, optional: true) ||
      load_and_authorize(:topic, :announce, optional: true) ||
      load_and_authorize(:discussion, :announce, optional: true) ||
      load_and_authorize(:poll, :announce, optional: true) ||
      load_and_authorize(:outcome, :announce, optional: false)
  end

  def recipient_target
    target_model.respond_to?(:topic) ? target_model.topic : target_model
  end

  def target_model
    load_and_authorize(:group, :show, optional: true) ||
      load_and_authorize(:topic, :show, optional: true) ||
      load_and_authorize(:discussion, :show, optional: true) ||
      load_and_authorize(:comment, :show, optional: true) ||
      load_and_authorize(:poll, :show, optional: true) ||
      load_and_authorize(:outcome, :show, optional: true)
  end
end

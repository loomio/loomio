class Api::V1::AnnouncementsController < Api::V1::RestfulController
  def audience
    current_user.ability.authorize! :show, target_model

    # Anonymous polls must never disclose who voted. 'voters' maps to
    # Poll#unmasked_voters (which does NOT self-mask, since it is also used for
    # internal notification targeting), and 'non_voters' reveals voters by
    # complement — so all voter-derived audiences are refused for anon polls.
    if target_model.respond_to?(:anonymous) &&
       target_model.anonymous &&
       ['voters', 'decided_voters', 'undecided_voters', 'non_voters'].include?(params[:recipient_audience])
      raise CanCan::AccessDenied
    end

    self.collection = AnnouncementService.audience_users(
      target_model,
      params[:recipient_audience],
      current_user,
      params[:exclude_members],
      params[:include_actor].present?
    )
    respond_with_collection
  end

  def new_member_count
    current_user.ability.authorize! :show, target_model

    count = UserInviter.new_members_count(
      parent_group: target_model.parent_or_self,
      user_ids: String(params[:recipient_user_xids]).split('x').map(&:to_i),
      emails: String(params[:recipient_emails_cmr]).split(',')
    )
    render json: {count: count}
  end

  # count for number of notifications that will be send
  def count
    count = UserInviter.count(
      actor: current_user,
      model: target_model,
      emails: String(params[:recipient_emails_cmr]).split(','),
      user_ids: String(params[:recipient_user_xids]).split('x').map(&:to_i),
      chatbot_ids: String(params[:recipient_chatbot_xids]).split('x').map(&:to_i),
      audience: params[:recipient_audience],
      usernames: String(params[:recipient_usernames]).split(','),
      exclude_members: params[:exclude_members].present?,
      include_actor: params[:include_actor].present?
    )
    render json: {count: count}
  end

  def search
    # if target model has no groups, no discussions, then draw from users groups and guest threads
    self.collection = if params[:existing_only]
      target_model.members.invitable_search(params[:q]).limit(50)
    else
      UserQuery.invitable_search(
        model: target_model,
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
      event = TopicService.invite(topic: target_model, actor: current_user, params: params)
      self.collection = TopicReader.where(topic_id: target_model.id, user_id: event.recipient_user_ids)
      respond_with_collection serializer: TopicReaderSerializer, root: :topic_readers
    elsif target_model.is_a?(Poll)
      self.collection = PollService.invite(poll: target_model, actor: current_user, params: params)
      respond_with_collection serializer: StanceSerializer, root: :stances
    elsif target_model.is_a?(Outcome)
      self.collection = OutcomeService.invite(outcome: target_model, actor: current_user, params: params)
      respond_with_collection serializer: UserSerializer, root: :users
    end
  end

  def users_notified_count
    # returns a count of users notified about this thing
    current_user.ability.authorize! :show, target_model

    count = Notification.
            joins(:event).
            where("events.id": target_event_ids).
            count("DISTINCT notifications.user_id")

    render json: {count: count}
  end

  def history
    authorize_history!

    notifications = {}

    events = Event.where(kind: notification_kinds, id: target_event_ids).order('id desc').limit(1000)

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

    Notification.includes(:user).where(event_id: events.pluck(:id)).order('users.name, users.email').each do |notification|
      next unless notification.user
      notifications[notification.event_id] = [] unless notifications.has_key?(notification.event_id)
      notifications[notification.event_id] << {id: notification.id, user_id: notification.user_id, viewed: allow_viewed && notification.viewed }
    end

    res = events.map do |event|
      {id: event.id,
       created_at: event.created_at,
       author_id: event.user_id,
       kind: event.kind,
       notifications: notifications[event.id] || [] }
    end.filter {|e| e[:notifications].size > 0}

    user_ids = res.flat_map { |e| [e[:author_id]] + e[:notifications].map { |n| n[:user_id] } }.uniq.compact
    users = User.where(id: user_ids).map { |u| AuthorSerializer.new(u).as_json(root: false) }
    render root: false, json: {allow_viewed: allow_viewed, data: res, users: users}
  end

  private

  def target_event_ids
    if target_model.is_a?(Topic)
      # topic_id on events identifies thread items only. Notification/edit
      # events (poll_announced, discussion_edited, user_mentioned, etc.) link
      # via eventable, so we match by topicable + in-thread polls + their
      # outcomes. For comments we match both thread-item events (topic_id = :t)
      # and notification events like user_mentioned whose eventable is a comment
      # in the thread but whose topic_id is NULL.
      discussion_ids = target_model.topicable_type == 'Discussion' ? [target_model.topicable_id] : []
      poll_ids       = Poll.where(topic_id: target_model.id).pluck(:id)
      outcome_ids    = Outcome.where(poll_id: poll_ids).pluck(:id)
      comment_ids    = Event.where(topic_id: target_model.id, eventable_type: 'Comment').pluck(:eventable_id)

      Event.where(kind: notification_kinds).where(<<~SQL, d: discussion_ids, p: poll_ids, o: outcome_ids, t: target_model.id, c: comment_ids).pluck(:id)
        (eventable_type = 'Discussion' AND eventable_id IN (:d)) OR
        (eventable_type = 'Poll'       AND eventable_id IN (:p)) OR
        (eventable_type = 'Outcome'    AND eventable_id IN (:o)) OR
        (eventable_type = 'Comment'    AND topic_id = :t) OR
        (eventable_type = 'Comment'    AND eventable_id IN (:c))
      SQL
    else
      Event.where(kind: notification_kinds, eventable: [target_model]).pluck(:id)
    end
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

  def target_model
    load_and_authorize(:group, :show, optional: true) ||
      load_and_authorize(:topic, :show, optional: true) ||
      load_and_authorize(:discussion, :show, optional: true) ||
      load_and_authorize(:comment, :show, optional: true) ||
      load_and_authorize(:poll, :show, optional: true) ||
      load_and_authorize(:outcome, :show, optional: true)
  end
end

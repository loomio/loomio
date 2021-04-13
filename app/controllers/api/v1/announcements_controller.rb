class API::V1::AnnouncementsController < API::V1::RestfulController
  def audience
    current_user.ability.authorize! :show, target_model
    raise CanCan::AccessDenied if target_model.respond_to?(:anonymous) and target_model.anonymous
    self.collection = AnnouncementService.audience_users(
      target_model,
      params[:recipient_audience],
      current_user,
      params[:exclude_members],
      params[:include_actor].present?
    )
    respond_with_collection
  end

  def count
    count = UserInviter.count(
      actor: current_user,
      model: target_model,
      emails: String(params[:recipient_emails_cmr]).split(','),
      user_ids: String(params[:recipient_user_xids]).split('x').map(&:to_i),
      audience: params[:recipient_audience],
      usernames: String(params[:recipient_usernames]).split(','),
      exclude_members: params[:exclude_members],
      include_actor: params[:include_actor].present?
    )
    render json: {count: count}
  end

  def search
    # if target model has no groups, no discussions, then draw from users groups and guest threads
    self.collection = if params[:existing_only]
      target_model.members.search_for(params[:q]).limit(50)
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
    # juggle data for older clients
    if params.dig(:announcement, :recipients)
      params[:recipient_user_ids] = params.dig(:announcement, :recipients, :user_ids)
      params[:recipient_emails] = params.dig(:announcement, :recipients, :emails)
    end

    %w[recipient_user_ids recipient_emails recipient_audience invited_group_ids message].each do |name|
      params[name] = params.dig(:announcement, name) if params.dig(:announcement, name)
    end

    if target_model.is_a?(Group)
      self.collection = GroupService.invite(group: target_model, actor: current_user, params: params)
      respond_with_collection serializer: MembershipSerializer, root: :memberships
    elsif target_model.is_a?(Discussion)
      event = DiscussionService.invite(discussion: target_model, actor: current_user, params: params)
      self.collection = DiscussionReader.where(discussion_id: target_model.id, user_id: event.recipient_user_ids)
      respond_with_collection serializer: DiscussionReaderSerializer, root: :discussion_readers
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
    notifications = {}

    events = Event.where(kind: notification_kinds, id: target_event_ids).order('id desc').limit(1000)

    Notification.includes(:user).where(event_id: events.pluck(:id)).order('users.name, users.email').each do |notification|
      next unless notification.user
      notifications[notification.event_id] = [] unless notifications.has_key?(notification.event_id)
      notifications[notification.event_id] << {id: notification.id, to: (notification.user.name || notification.user.email), viewed: notification.viewed}
    end

    res = events.map do |event|
      {event_id: event.id,
       created_at: event.created_at,
       author_name: event.user.name,
       kind: event.kind,
       notifications: notifications[event.id] || [] }
    end.filter {|e| e[:notifications].size > 0}

    render root: false, json: res
  end

  private

  def target_event_ids
    if target_model.is_a?(Discussion)
      polls = Poll.where(discussion_id: target_model.id)
      outcomes = Outcome.where(poll_id: polls.map(&:id))
      comments = Comment.where(discussion_id: target_model.id)
      eventables = [target_model, polls, outcomes, comments].flatten.compact
    else
      eventables = [target_model]
    end

    event_ids = Event.where(kind: notification_kinds, eventable: eventables).pluck(:id)
  end

  def notification_kinds
    %w[announcement_created
      user_mentioned
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

  def default_scope
    super.merge(
      include_email: (target_model && target_model.admins.exists?(current_user.id))
    )
  end

  def authorize_model
    load_and_authorize(:group, :announce, optional: true) ||
    load_and_authorize(:discussion, :announce, optional: true) ||
    load_and_authorize(:poll, :announce, optional: true) ||
    load_and_authorize(:outcome, :announce, optional: false)
  end

  def target_model
    load_and_authorize(:group, :show, optional: true) ||
    load_and_authorize(:discussion, :show, optional: true) ||
    load_and_authorize(:comment, :show, optional: true) ||
    load_and_authorize(:poll, :show, optional: true) ||
    load_and_authorize(:outcome, :show, optional: true)
  end
end

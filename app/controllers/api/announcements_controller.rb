class API::AnnouncementsController < API::RestfulController
  MockEvent = Struct.new(:eventable, :email_subject_key, :user, :id)

  def audience
    self.collection = service.audience_users(target_model, params.require(:kind))

    if params[:without_exising]
      self.collection = collection.where.not(id: target_model.existing_member_ids)
    end

    if params[:return_users]
      respond_with_collection serializer: AuthorSerializer, root: false
    else
      respond_with_collection serializer: AnnouncementRecipientSerializer, root: false
    end
  end

  def create
    current_user.ability.authorize! :announce, target_model

    # juggle data for older clients
    if params.dig(:announcement, :recipients)
      params[:recipient_user_ids] = params.dig(:announcement, :recipients, :user_ids)
      params[:recipient_emails] = params.dig(:announcement, :recipients, :emails)
    end

    %w[recipient_user_ids recipient_emails recipient_audience invited_group_ids message].each do |name|
      params[name] = params.dig(:announcement, name) if params.dig(:announcement, name)
    end

    if target_model.is_a?(Group)
      self.collection = GroupService.announce(group: target_model, actor: current_user, params: params)
      respond_with_collection serializer: MembershipSerializer, root: :memberships
    elsif target_model.is_a?(Discussion)
      event = DiscussionService.announce(discussion: target_model, actor: current_user, params: params)
      self.collection = DiscussionReader.where(discussion_id: target_model.id, user_id: event.recipient_user_ids)
      respond_with_collection serializer: DiscussionReaderSerializer, root: :discussion_readers
    elsif target_model.is_a?(Poll)
      self.collection = PollService.announce(poll: target_model, actor: current_user, params: params)
      respond_with_collection serializer: StanceSerializer, root: :stances
    elsif target_model.is_a?(Outcome)
      self.collection = OutcomeService.announce(outcome: target_model, actor: current_user, params: params)
      respond_with_collection serializer: UserSerializer, root: :users
    end
  end

  def search
    self.collection = Queries::AnnouncementRecipients.new(params.require(:q), current_user, target_model).results
    respond_with_collection serializer: AnnouncementRecipientSerializer, root: false
  end

  def history
    notifications = {}

    kinds = %w[
      announcement_created
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
      new_discussion
      discussion_edited
      comment_replied_to
      poll_closing_soon]

    events = Event.where(kind: kinds, eventable: history_model).order('id').limit(50)

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
    end

    render root: false, json: res
  end

  def preview
    event = target_model.created_event
    @email = target_model.send(:mailer).send(params[:kind], current_user, event)
    @email.perform_deliveries = false

    render template: '/user_mailer/last_email.html', layout: false
  end

  private
  def default_scope
    super.merge include_email: target_model.admins.exists?(current_user.id)
  end

  def target_model
    @target_model ||=
      load_and_authorize(:group, :announce, optional: true) ||
      load_and_authorize(:discussion, :announce, optional: true) ||
      load_and_authorize(:poll, :announce, optional: true) ||
      load_and_authorize(:outcome, :announce, optional: false)
  end

  def history_model
      load_and_authorize(:group, :show, optional: true) ||
      load_and_authorize(:discussion, :show, optional: true) ||
      load_and_authorize(:comment, :show, optional: true) ||
      load_and_authorize(:poll, :show, optional: true) ||
      load_and_authorize(:outcome, :show, optional: false)
  end
end

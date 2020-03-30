class API::AnnouncementsController < API::RestfulController
  MockEvent = Struct.new(:eventable, :email_subject_key, :user, :id)

  def audience
    self.collection = service.audience_for(target_model, params.require(:kind), current_user)
    respond_with_collection serializer: AnnouncementRecipientSerializer, root: false
  end

  def create
    current_user.ability.authorize! :announce, target_model

    # juggle data
    if params[:announcement]
      params[:emails] = params.dig(:announcement, :recipients, :emails)
      params[:user_ids] = params.dig(:announcement, :recipients, :user_ids)
    end

    if target_model.is_a?(Group)
      self.collection = GroupService.announce(group: target_model, actor: current_user, params: params)
      respond_with_collection serializer: MembershipSerializer, root: :memberships
    elsif target_model.is_a?(Discussion)
      self.collection = DiscussionService.announce(discussion: target_model, actor: current_user, params: params)
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

    events = Event.where(kind: ['announcement_created', 'user_mentioned', 'announcement_resend'], eventable: history_model).order('id').limit(50)

    Notification.includes(:user).where(event_id: events.pluck(:id)).order('users.name, users.email').each do |notification|
      next unless notification.user
      notifications[notification.event_id] = [] unless notifications.has_key?(notification.event_id)
      notifications[notification.event_id] << {id: notification.id, to: (notification.user.name || notification.user.email), viewed: notification.viewed}
    end
    res = events.map do |event|
      {event_id: event.id,
       created_at: event.created_at,
       author_name: event.user.name,
       notifications: notifications[event.id] || [] }
    end

    render root: false, json: res
  end

  def preview
    event = MockEvent.new(target_model, nil, current_user , 1)
    @email = target_model.send(:mailer).send(params[:kind], current_user, event)
    @email.perform_deliveries = false

    render template: '/user_mailer/last_email.html', layout: false
  end

  private

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

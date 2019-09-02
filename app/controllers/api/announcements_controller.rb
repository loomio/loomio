class API::AnnouncementsController < API::RestfulController
  MockEvent = Struct.new(:eventable, :email_subject_key)

  def audience
    self.collection = service.audience_for(target_model, params.require(:kind), current_user)
    respond_with_collection serializer: AnnouncementRecipientSerializer, root: false
  end

  def create
    self.collection = service.create(model: target_model, params: resource_params, actor: current_user).memberships
    respond_with_collection serializer: MembershipSerializer, root: :memberships, scope: create_scope
  end

  def search
    self.collection = Queries::AnnouncementRecipients.new(params.require(:q), current_user, target_model).results
    respond_with_collection serializer: AnnouncementRecipientSerializer, root: false
  end

  def history
    json = Event.where(kind: 'announcement_created', eventable: target_model).order('id').limit(10).map do |event|
      {event_id: event.id,
       created_at: event.created_at,
       author_name: event.user.name,
       notifications: notifications_for(event) }
    end
    render json: json, root: false
  end

  def preview  
    event = MockEvent.new(target_model, nil)
    @email = target_model.send(:mailer).send(params[:kind], current_user, event)
    @email.perform_deliveries = false

    render template: '/user_mailer/last_email.html', layout: false
  end

  private
  def notifications_for(event)
    Notification.joins(:user).where(event_id: event.id).map do |notification|
      {id: notification.id,
       to: notification.user.name || notification.user.email,
       viewed: notification.viewed}
    end
  end

  def create_scope
    { email_user_ids: collection.pending.pluck(:user_id) }
  end

  def target_model
    @target_model ||=
      load_and_authorize(:group, :announce, optional: true) ||
      load_and_authorize(:discussion, :announce, optional: true) ||
      load_and_authorize(:poll, :announce, optional: true) ||
      load_and_authorize(:outcome, :announce, optional: false)
  end
end

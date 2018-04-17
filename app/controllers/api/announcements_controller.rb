class API::AnnouncementsController < API::RestfulController
  def audience
    self.collection = service.audience_for(notified_model, params.require(:kind), current_user)
    respond_with_collection serializer: AnnouncementRecipientSerializer, root: false
  end

  def create
    @event = service.create(model: notified_model, params: resource_params, actor: current_user)
    render json: { users_count: @event.notifications.length }
  end

  def search
    self.collection = Queries::AnnouncementRecipients.new(params.require(:q), current_user, notified_group).results
    respond_with_collection serializer: AnnouncementRecipientSerializer, root: false
  end

  private

  def notified_group
    @notified_group ||= load_and_authorize(:group, :invite_people, optional: true) || NullFormalGroup.new
  end

  def notified_model
    @notified_model ||=
      load_and_authorize(:group, optional: true) ||
      load_and_authorize(:discussion, optional: true) ||
      load_and_authorize(:poll, optional: true) ||
      load_and_authorize(:outcome)
  end
end

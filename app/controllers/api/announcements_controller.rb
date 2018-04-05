class API::AnnouncementsController < API::RestfulController
  def create
    @events = service.create(model: notified_model, params: resource_params, actor: current_user)
    render json: { users_count: @events.length }
  end

  def search
    self.collection = Queries::AnnouncementRecipients.new(params.require(:q), current_user).results
    respond_with_collection serializer: AnnouncementRecipientSerializer, root: false
  end

  private

  def accessible_records
    notified_model.announcements
  end

  def notified_model
    @notified_model ||=
      load_and_authorize(:group, optional: true) ||
      load_and_authorize(:discussion, optional: true) ||
      load_and_authorize(:poll, optional: true) ||
      load_and_authorize(:outcome)
  end
end

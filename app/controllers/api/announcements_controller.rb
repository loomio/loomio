class API::AnnouncementsController < API::RestfulController
  def index
    instantiate_collection
    respond_with_collection scope: index_scope
  end

  def create
    @events = service.create(model: notified_model, params: resource_params, actor: current_user)
    render json: { users_count: @events.length }
  end

  def notified
    self.collection = Queries::Notified::Search.new(params.require(:q), current_user).results
    respond_with_collection serializer: NotifiedSerializer, root: false
  end

  def notified_default
    self.collection = Queries::Notified::Default.new(params.require(:kind), notified_model, current_user).results
    respond_with_collection serializer: NotifiedSerializer, root: false
  end

  def members
    self.collection = Queries::Notified::Members.new(notified_model, params[:expand_group]).results
    respond_with_collection serializer: MemberSerializer, root: :members
  end

  private

  def index_scope
    {
      users:       User.where(id: resources_to_serialize.map(&:user_ids).flatten),
      invitations: Invitation.where(id: resources_to_serialize.map(&:invitation_ids).flatten)
    }
  end

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

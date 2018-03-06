class API::AnnouncementsController < API::RestfulController
  def index
    instantiate_collection
    respond_with_collection scope: index_scope
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
    self.collection = notified_model.members.with_last_notified_for(notified_model)
    respond_with_collection serializer: Simple::UserSerializer, scope: { notified_model: notified_model }, root: false
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
      load_and_authorize(:discussion, optional: true) ||
      load_and_authorize(:poll, optional: true) ||
      load_and_authorize(:outcome)
  end
end

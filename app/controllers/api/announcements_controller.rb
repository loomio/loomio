class API::AnnouncementsController < API::RestfulController
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

  private
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

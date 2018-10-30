class API::AnnouncementsController < API::RestfulController
  def audience
    self.collection = service.audience_for(notified_model, params.require(:kind), current_user)
    respond_with_collection serializer: AnnouncementRecipientSerializer, root: false
  end

  def create
    self.collection = service.create(model: notified_model, params: resource_params, actor: current_user).memberships
    respond_with_collection serializer: MembershipSerializer, root: :memberships, scope: create_scope
  end

  def search
    self.collection = Queries::AnnouncementRecipients.new(params.require(:q), current_user, notified_model).results
    respond_with_collection serializer: AnnouncementRecipientSerializer, root: false
  end

  private
  def create_scope
    { email_user_ids: collection.pending.pluck(:user_id) }
  end

  # # GK: TODO: why would we use this instead of notified_model?
  # def notified_group
  #   # GK: TODO: group key is being passed into load_and_authorize, but it could be a poll or discussion
  #   # therefore, load_and_authorize is returning nil
  #   # and therefore, NullFormalGroup is initialised
  #   @notified_group ||= load_and_authorize(:group, :invite_people, optional: true) || NullFormalGroup.new
  # end

  def notified_model
    @notified_model ||=
      load_and_authorize(:group, optional: true) ||
      load_and_authorize(:discussion, optional: true) ||
      load_and_authorize(:poll, optional: true) ||
      load_and_authorize(:outcome)
  end
end

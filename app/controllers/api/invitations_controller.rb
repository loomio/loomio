class API::InvitationsController < API::RestfulController
  def shareable
    self.collection = Array(authorize_group(:view_shareable_invitation).shareable_invitation)
    respond_with_collection
  end
  
  private
  def authorize_group(ability)
    load_and_authorize(:poll, ability, optional: true)&.guest_group ||
    load_and_authorize(:group, ability)
  end
end

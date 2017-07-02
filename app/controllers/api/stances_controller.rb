class API::StancesController < API::RestfulController
  alias :update :create
  before_action :set_guest_params, only: :create

  def my_stances
    self.collection = current_user.stances.latest.includes({poll: :discussion})
    self.collection = collection.where('polls.discussion_id': @discussion.id) if load_and_authorize(:discussion, optional: true)
    self.collection = collection.where('discussions.group_id': @group.id)     if load_and_authorize(:group, optional: true)
    respond_with_collection
  end

  private

  def set_guest_params
    return if current_user.is_logged_in?
    current_user.name  = guest_params[:name]
    current_user.email = guest_params[:email]
  end

  def guest_params
    @guest_params ||= Hash(resource_params.delete(:visitor_attributes))
  end

  def accessible_records
    apply_order load_and_authorize(:poll).stances.latest
  end

  def apply_order(collection)
    if resource_class::ORDER_SCOPES.include?(params[:order].to_s)
      collection.send(params[:order])
    else
      collection
    end
  end

end

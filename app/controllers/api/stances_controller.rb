class API::StancesController < API::RestfulController
  alias :update :create

  def my_stances
    self.collection = current_user.stances.latest.includes({poll: :discussion})
    self.collection = collection.where('polls.discussion_id': @discussion.id) if load_and_authorize(:discussion, optional: true)
    self.collection = collection.where('discussions.group_id': @group.id)     if load_and_authorize(:group, optional: true)
    respond_with_collection
  end

  private

  def create_action
    @event = service.create(stance: resource, actor: current_user.presence || update_visitor)
  end

  def update_visitor
    (current_visitor.presence || Visitor.new).tap do |visitor|
      visitor.assign_attributes(Hash(resource_params[:visitor_attributes]).slice(:name, :email))
      visitor.community ||= resource.poll.community_of_type(:public)
    end
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

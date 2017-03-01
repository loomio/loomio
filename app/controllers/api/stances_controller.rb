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
    @event = service.create(stance: resource, actor: current_user.presence || identify_visitor)
    set_participation_cookie if events_to_serialize.any?
  end

  def identify_visitor
    VisitorIdentifier.new(resource_params.fetch(:visitor_attributes, {})).identify_for(resource.poll)
  end

  def set_participation_cookie
    cookies[:participation_token] = {
      value:      resource.participant.participation_token,
      expires_at: resource.poll.closing_at
    }
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

class API::PollsController < API::RestfulController
  load_and_authorize_resource only: :show

  def index
    instantiate_collection do |collection|
      collection = collection.where(discussion: @discussion) if load_and_authorize(:discussion, optional: true)
      collection.order(:created_at)
    end
    respond_with_collection
  end

  def closed
    instantiate_collection do |collection|
      collection.closed.where(discussion_id: load_and_authorize(:group).discussion_ids).order(closed_at: :desc)
    end
    respond_with_collection
  end

  def close
    service.close(poll: load_and_authorize(:poll, :close), actor: current_user)
    respond_with_resource
  end

  private

  def resource_params
    template = resource_class.template_for(params.dig(resource_name, :poll_type))
    super.reverse_merge(template).permit!
  end

  def accessible_records
    Queries::VisiblePolls.new(user: current_user)
  end
end

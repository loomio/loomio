class API::PollsController < API::RestfulController
  load_and_authorize_resource only: :show

  def index
    instantiate_collection do |collection|
      collection = collection.where(discussion: @discussion) if load_and_authorize(:discussion, optional: true)
      collection = collection.active                         if params[:active]
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

  def accessible_records
    Queries::VisiblePolls.new(user: current_user)
  end
end

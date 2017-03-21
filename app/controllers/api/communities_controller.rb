class API::CommunitiesController < API::RestfulController

  def index
    instantiate_collection do |collection|
      collection = collection.where(community_type: params[:types]) if params[:types]
      collection
    end
    respond_with_collection
  end

  private

  def accessible_records
    (load_and_authorize(:poll, optional: true) || current_user).communities
  end

  def resource_class
    Communities::Base
  end

  def default_scope
    { poll_id: @poll.id } if @poll
  end
end

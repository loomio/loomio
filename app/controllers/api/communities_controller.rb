class API::CommunitiesController < API::RestfulController

  def index
    instantiate_collection do |collection|
      collection = collection.where(community_type: params[:types].split(',')) if params[:types]
      collection
    end
    respond_with_collection
  end

  def add
    service.add(community: load_resource, actor: current_user, poll: load_and_authorize(:poll))
    respond_with_resource
  end

  def remove
    service.remove(community: load_resource, actor: current_user, poll: load_and_authorize(:poll))
    respond_with_resource
  end

  private

  def accessible_records
    load_and_authorize(:poll, :share).communities
  end

  def resource_class
    Communities::Base
  end

  def default_scope
    { poll_id: @poll.id } if @poll
  end
end

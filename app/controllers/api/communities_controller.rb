class API::CommunitiesController < API::RestfulController

  def index
    instantiate_collection do |collection|
      collection = collection.where(community_type: params[:types].split(',')) if params[:types]
      collection
    end
    respond_with_collection
  end

  private

  def accessible_records
    load_and_authorize(:poll, :share).communities
  end

  def instantiate_resource
    self.resource = existing_resource || super
  end

  def existing_resource
    resource_class.find_by(resource_params.slice(:identity_id, :identifier, :community_type)).tap do |existing|
      existing.poll_id = resource_params[:poll_id] if existing
    end
  end

  def resource_class
    Communities::Base
  end

  def default_scope
    { poll_id: @poll.id } if @poll
  end
end

class API::PollCommunitiesController < API::RestfulController

  private

  def load_resource
    resource_class.find_by(resource_params)
  end

  def instantiate_resource
    resource_class.new(poll: load_and_authorize(:poll), community: instantiate_community)
  end

  def instantiate_community
    Communities::Base.find_by(community_params.slice(:identifier, :community_type, :identity_id) ||
    Communities::Base.new(community_params.slice(:identifier, :community_type, :identity_id, :custom_fields))
  end

  def community_params
    params.require(:community)
  end

  def resources_to_serialize
    Array(self.resource.community)
  end
end

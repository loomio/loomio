class API::PollCommunitiesController < API::RestfulController

  private

  def load_resource
    self.resource = resource_class.find_by(params.slice(:poll_id, :community_id))
  end

  def resources_to_serialize
    Array(self.resource.community)
  end
end

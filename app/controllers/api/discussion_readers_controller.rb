class API::DiscussionReadersController < API::RestfulController

  def load_resource
    load_and_authorize_discussion
    self.resource = DiscussionReader.for(user: current_user, discussion: @discussion)
  end

end

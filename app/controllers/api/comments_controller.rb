class API::CommentsController < API::RestfulController
  include UsesDiscussionReaders

  def like
    service.like(comment: load_resource, actor: current_user)
    respond_with_resource
  end

  def unlike
    service.unlike(comment: load_resource, actor: current_user)
    respond_with_resource
  end
end

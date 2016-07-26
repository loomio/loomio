class Api::CommentsController < Api::RestfulController
  include UsesDiscussionReaders

  def like
    service.like(comment: fetch_resource, actor: current_user)
    respond_with_resource
  end

  def unlike
    service.unlike(comment: fetch_resource, actor: current_user)
    respond_with_resource
  end
end

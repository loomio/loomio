class CommentsController < BaseController
  load_and_authorize_resource

  def destroy
    flash[:notice] = "Comment deleted."
    destroy!{ motion_path(resource.discussion.motions.first) }
  end
end

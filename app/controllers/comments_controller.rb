class CommentsController < BaseController
  load_and_authorize_resource

  def destroy
    flash[:notice] = "Comment deleted."
    destroy!{ motion_path(resource.current_motion) }
  end

  def like
    resource.like current_user
    redirect_to motion_path(resource.current_motion)
  end

  def unlike
    resource.unlike current_user
    redirect_to motion_path(resource.current_motion)
  end
end

class CommentsController < BaseController
  load_and_authorize_resource

  def destroy
    flash[:notice] = "Comment deleted."
    destroy!{ discussion_path(resource.dicussion) }
  end

  def like
    resource.like current_user
    redirect_to discussion_path(resource.discussion)
  end

  def unlike
    resource.unlike current_user
    redirect_to discussion_path(resource.discussion)
  end
end

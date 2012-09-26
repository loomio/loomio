class CommentsController < BaseController
  load_and_authorize_resource

  def destroy
    destroy!{ discussion_url(resource.discussion) }
  end

  def like
    @comment = Comment.find(params[:id])
    comment_vote = resource.like current_user
    Event.comment_liked!(comment_vote)
    respond_to do |format|
    	format.html { redirect_to discussion_url(resource.discussion) }
    	format.js { render :template => "comments/comment_likes" }
    end
  end

  def unlike
  @comment = Comment.find(params[:id])
    resource.unlike current_user
    respond_to do |format|
    	format.html { redirect_to discussion_url(resource.discussion) }
    	format.js { render :template => "comments/comment_likes" }
    end
  end
end

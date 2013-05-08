class CommentsController < BaseController
  inherit_resources
  load_and_authorize_resource

  def destroy
    destroy!{ discussion_url(resource.discussion) }
  end

  def like
    @comment = resource
    like = (params[:like]=='true')
    if like
      comment_vote = @comment.like current_user
      @comment.reload
      Events::CommentLiked.publish!(comment_vote)
    else
      @comment.unlike current_user
      @comment.reload
    end
    respond_to do |format|
    	format.html { redirect_to discussion_url(@comment.discussion) }
    	format.js { render :template => "comments/comment_likes" }
    end
  end
end

class CommentsController < BaseController
  load_and_authorize_resource

  def destroy
    CommentDeleter.new(@comment).delete_comment
    flash[:notice] = t(:"notice.comment_deleted")
    redirect_to discussion_url(@comment.discussion)
  end

  def like
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

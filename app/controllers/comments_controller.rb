class CommentsController < BaseController
  load_and_authorize_resource only: :destroy

  def destroy
    CommentDeleter.new(@comment).delete_comment
    flash[:notice] = t(:"notice.comment_deleted")
    redirect_to discussion_url(@comment.discussion)
  end

  def like
    @comment = Comment.find(params[:id])
    if can? :like_comments, @comment.discussion
      like = (params[:like]=='true')
      if like
        comment_vote = @comment.like current_user
        Events::CommentLiked.publish!(comment_vote)
      else
        @comment.unlike current_user
        @comment.reload
      end
      render :template => "comments/comment_likes"
    else
      head :bad_request
    end
  end
end

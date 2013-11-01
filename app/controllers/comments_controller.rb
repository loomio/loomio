class CommentsController < BaseController
  load_and_authorize_resource only: :destroy

  def destroy
    CommentDeleter.new(@comment).delete_comment
    flash[:notice] = t(:"notice.comment_deleted")
    redirect_to discussion_url(@comment.discussion)
  end

  def like
    @comment = Comment.find(params[:id])

    if params[:like] == 'true'
      DiscussionService.like_comment(current_user, @comment)
    else
      DiscussionService.unlike_comment(current_user, @comment)
    end

    render :template => "comments/comment_likes"
  end
end

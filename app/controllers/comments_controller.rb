class CommentsController < BaseController
  load_and_authorize_resource only: :destroy
  load_resource only: [:like, :translate]
  skip_before_filter :authenticate_user!, only: :translate

  def destroy
    CommentDeleter.new(@comment).delete_comment
    flash[:notice] = t(:"notice.comment_deleted")
    redirect_to discussion_url(@comment.discussion)
  end

  def like
    if params[:like] == 'true'
      Measurement.increment('comments.like.success')
      DiscussionService.like_comment(current_user, @comment)
    else
      Measurement.increment('comments.unlike.success')
      DiscussionService.unlike_comment(current_user, @comment)
    end
    @discussion = @comment.discussion

    render :template => "comments/comment_likes"
  end
  
  def translate
    raise NotImplementedError # (temporarily disable translation feature) 
  end

end

class CommentsController < BaseController
  load_and_authorize_resource

  def destroy
    CommentService.destroy(comment: @comment, actor: current_user)
    flash[:notice] = t(:"notice.comment_deleted")
    redirect_to discussion_url(@comment.discussion)
  end

  def edit
  end

  def update
    if CommentService.update(comment: @comment,
                             params: permitted_params.comment,
                             actor: current_user)
      redirect_to discussion_path(@comment.discussion, anchor: "comment-#{@comment.id}")
    else
      render :edit
    end
  end

  def show
  end

  def like
    if params[:like] == 'true'
      Measurement.increment('comments.like.success')
      CommentService.like(comment: @comment, actor: current_user)
    else
      Measurement.increment('comments.unlike.success')
      CommentService.unlike(comment: @comment, actor: current_user)
    end
    @discussion = @comment.discussion

    render :template => "comments/comment_likes"
  end

end

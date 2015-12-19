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
    @comment.uses_markdown = params[:comment].has_key? "uses_markdown"
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
    CommentService.like(comment: @comment, actor: current_user)
    @comment.reload
    render template: "comments/comment_likes"
  end

  def unlike
    CommentService.unlike(comment: @comment, actor: current_user)
    @comment.reload
    render template: "comments/comment_likes"
  end

end

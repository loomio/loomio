class CommentsController < BaseController
  load_and_authorize_resource

  def destroy
    destroy!{ discussion_url(resource.discussion) }
  end

  def edit
  end

  def update
    @comment.edit_body!(params[:comment][:body])
    redirect_to @comment.discussion
  end

  def show
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

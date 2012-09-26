class CommentsController < BaseController
  load_and_authorize_resource

  def destroy
    destroy!{ discussion_url(resource.discussion) }
  end

  def like
  	@comment = Comment.find(params[:id])
    like = (params[:like]=='true')
    if like 
      comment_vote = resource.like current_user
      Event.comment_liked!(comment_vote)
    else
      resource.unlike current_user
    end
    respond_to do |format|
    	format.html { redirect_to discussion_url(resource.discussion) }
    	format.js { render :template => "comments/comment_likes" }
    end
  end

end

class CommentsController < BaseController
  load_and_authorize_resource

  def destroy
    destroy!{ discussion_url(resource.discussion ) }
  end

  def like
    comment_vote = resource.like current_user
    Event.comment_liked!(comment_vote)
    #redirect_to discussion_url(resource.discussion )
  end

  def unlike
    resource.unlike current_user
    #redirect_to discussion_url(resource.discussion)
  end

end

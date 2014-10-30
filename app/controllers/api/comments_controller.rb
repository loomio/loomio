class API::CommentsController < API::RestfulController
  before_filter :authenticate_user_by_email_api_key, only: :create
  before_filter :require_authenticated_user
  load_resource only: [:like, :unlike]

  def index
    @comments = Comment.where(discussion: @discussion).order(:created_at)
    respond_with_collection
  end

  def create
    DiscussionService.add_comment(@comment)
    respond_with_resource
  end

  def update
    DiscussionService.edit_comment(current_user, permitted_params, @comment)
    respond_with_resource
  end

  def like
    DiscussionService.like_comment(current_user, @comment)
    respond_with_resource
  end

  def unlike
    DiscussionService.unlike_comment(current_user, @comment)
    respond_with_resource
  end

end

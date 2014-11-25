class API::CommentsController < API::RestfulController
  skip_before_filter :require_authenticated_user

  before_filter :authenticate_user_by_email_api_key, only: :create
  before_filter :require_authenticated_user

  load_resource only: [:like, :unlike]

  def create
    instantiate_resouce
    event = service.create({resource_symbol => resource,
                    actor: current_user})

    if resource.valid?
      render json: [event], each_serializer: EventSerializer, root: 'events'
    else
      render json: { errors: resource.errors }, status: 400
    end
  end

  def like
    CommentService.like(comment: @comment, actor: current_user)
    respond_with_resource
  end

  def unlike
    CommentService.unlike(comment: @comment, actor: current_user)
    respond_with_resource
  end
end

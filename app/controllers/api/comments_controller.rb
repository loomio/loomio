class API::CommentsController < API::RestfulController
  def discard
    load_resource
    @event = service.discard(comment: resource, actor: current_user)
    respond_with_resource(scope: default_scope.merge(exclude_types: %w[discussion group user]))
  end

  def undiscard
    load_resource
    @event = service.undiscard(comment: resource, actor: current_user)
    respond_with_resource(scope: {exclude_types: %w[discussion group user]})
  end

  def destroy
    load_resource
    @event = @comment.created_event.parent
    destroy_action
    @event.reload
    render json: MessageChannelService.serialize_models(@event.children.compact, scope: default_scope)
  end
end

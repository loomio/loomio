class Api::V1::CommentsController < Api::V1::RestfulController
  def discard
    load_resource
    service.discard(comment: resource, actor: current_user) { |topic_item| @topic_item = topic_item }
    respond_with_resource(scope: default_scope.merge(exclude_types: %w[discussion group user]))
  end

  def undiscard
    load_resource
    service.undiscard(comment: resource, actor: current_user) { |topic_item| @topic_item = topic_item }
    respond_with_resource(scope: {exclude_types: %w[discussion group user]})
  end

  def destroy
    load_resource
    parent_topic_item = @comment.created_topic_item.parent
    destroy_action
    parent_topic_item.reload
    render json: MessageChannelService.serialize_models(parent_topic_item.children.compact, scope: default_scope)
  end
end

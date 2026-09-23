class Api::B2::CommentsController < Api::B2::BaseController
  def create
    instantiate_resource
    if params[:discussion_id] && resource.parent_id.blank?
      resource.parent_type = 'Discussion'
      resource.parent_id = params[:discussion_id]
    end
    raise CanCan::AccessDenied unless resource.parent_id.present?
    self.resource = CommentService.create(comment: resource, actor: current_user)
    respond_with_resource
  end

  def update
    load_resource
    self.resource = CommentService.update(comment: resource, params: resource_params, actor: current_user)
    respond_with_resource
  end

  def destroy
    load_resource
    CommentService.discard(comment: resource, actor: current_user)
    respond_with_resource
  end

end

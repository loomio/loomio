class Api::B2::CommentsController < Api::B2::BaseController
  def create
    instantiate_resource
    if params[:discussion_id] && resource.parent_id.blank?
      resource.parent_type = 'Discussion'
      resource.parent_id = params[:discussion_id]
    end
    raise CanCan::AccessDenied unless resource.parent_id.present?
    if CommentService.create(comment: resource, actor: current_user)
      respond_with_resource
    else
      respond_with_errors
    end
  end

  private

  def permitted_params
    jarams = params.dup
    if jarams[:api_key]
      jarams.delete(:api_key)
      jarams.delete(:format)
      jarams.delete(:discussion_id)
      jarams.delete(:discussion)
      jarams = ActionController::Parameters.new({resource_name => jarams})
    end
    @permitted_params ||= PermittedParams.new(jarams)
  end
end

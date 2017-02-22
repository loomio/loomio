class API::DraftsController < API::RestfulController
  before_filter :load_resource

  private

  def load_resource
    current_user.ability.authorize! :make_draft, draftable
    self.resource = resource_class.find_or_initialize_by(user: current_user, draftable: draftable)
  end

  def draftable
    return unless resource_class::DRAFTABLE_MODELS.include? params[:draftable_type]
    @draftable ||= params[:draftable_type].classify.constantize.find(params[:draftable_id])
  end

  def resource_params
    params.require(:draft).slice(:payload)
  end

end

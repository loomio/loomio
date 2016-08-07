class Api::DraftsController < Api::RestfulController
  skip_before_action :fetch_and_authorize_resource, only: :show

  private

  def load_resource
    current_user.ability.authorize! :make_draft, draftable
    self.resource = Draft.find_or_initialize_by(user: current_user, draftable: draftable)
  end

  def draftable
    return unless ['user', 'group', 'discussion', 'motion'].include? params[:draftable_type]
    @draftable ||= params[:draftable_type].classify.constantize.find(params[:draftable_id])
  end

  def resource_params
    params.require(:draft).slice(:payload)
  end

end

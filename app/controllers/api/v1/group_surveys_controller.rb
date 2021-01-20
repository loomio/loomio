class API::V1::GroupSurveysController < API::V1::RestfulController

  def create
    service.create(params: resource_params, actor: current_user)
    render json: { success: :ok }
  end
end

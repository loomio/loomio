class Api::User0::ReportsController < Api::User0::BaseController
  def index
    render json: ParticipationReportService.fetch(actor: current_user, params: params, instance_admin_access: false)
  end
end

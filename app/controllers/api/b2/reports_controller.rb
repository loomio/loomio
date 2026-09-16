class Api::B2::ReportsController < Api::B2::BaseController
  def index
    render json: ParticipationReportService.fetch(actor: current_user, params: params)
  end
end

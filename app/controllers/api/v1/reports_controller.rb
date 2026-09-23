class Api::V1::ReportsController < Api::V1::RestfulController
  def index
    render json: ParticipationReportService.fetch(actor: current_user, params: params)
  end
end

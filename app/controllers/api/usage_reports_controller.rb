class API::UsageReportsController < ActionController::Base
  def create
    UsageReport.create!(params[:usage_report]) if ENV['HOSTED_BY_LOOMIO']
    head :ok
  end

  private
  def params
    request.parameters
  end
end

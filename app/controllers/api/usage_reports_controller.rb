class API::UsageReportsController < ApplicationController
  def create
    UsageReport.create!(params[:usage_report])
    head :ok
  end

  private
  def params
    request.parameters
  end
end

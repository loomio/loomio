class API::UsageReportsController < ApplicationController
  def create
    UsageReport.create!(params[:usage_report]) if hosted_by_loomio?
    head :ok
  end

  private
  def params
    request.parameters
  end
end

class Clients::Loomio < Clients::Base
  def send_usage_report!(usage_report)
    post "usage_reports", params: { usage_report: usage_report }
  end

  private
  def require_json_payload?
    true
  end


  def default_host
    "#{ENV['USAGE_REPORT_URL']}/api/v1".freeze
  end
end

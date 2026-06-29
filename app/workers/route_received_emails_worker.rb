class RouteReceivedEmailsWorker < ApplicationJob
  def perform
    ReceivedEmailService.route_all
  end
end

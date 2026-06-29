class ImportGroupWorker < ApplicationJob
  def perform(url)
    GroupExportService.import(url)
  end
end

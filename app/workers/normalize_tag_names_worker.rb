class NormalizeTagNamesWorker < ApplicationJob
  queue_as :low

  def perform
    TagService.normalize_all_tag_names
  end
end

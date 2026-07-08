class GroomDuplicateTagsWorker < ApplicationJob
  def perform
    TagService.groom_duplicate_tags
  end
end

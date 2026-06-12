class DestroyGroupWorker < ApplicationJob
  def perform(group_id)
    begin
      Group.archived.find(group_id).try(:destroy!)
    rescue ActiveRecord::RecordNotFound
      puts "no need to worry, group must have been unarchived"
    end
  end
end

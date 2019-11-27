class GroupExportJob < ActiveJob::Base
  queue_as :low_priority

  def perform(group_ids:, group_name:, actor:)
    groups = Group.where(id: group_ids)
    filename = GroupExportService.export(groups, group_name)
    document = Document.create(author: actor, file: File.open(filename), title: filename)
    UserMailer.group_export_ready(actor, group_name, document).deliver
    document.delay(queue: :low_priority, run_at: 1.week.from_now).destroy!
  end
end

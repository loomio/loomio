class GroupExportJob < ActiveJob::Base
  queue_as :low_priority

  def perform(group, actor)
    groups = actor.groups.where(id: group.all_groups)
    filename = GroupExportService.export_filename_for(group)
    GroupExportService.export(groups, filename)
    document = Document.new(author: actor, title: filename)
    file = File.open(filename)
    document.file = file
    file.close
    document.save!
    UserMailer.group_export_ready(actor, group, document).deliver
    document.delay(:run_at => 1.week.from_now).destroy!
  end
end

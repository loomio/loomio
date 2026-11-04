class GroupExportWorker < ApplicationJob
  def perform(group_id, requestor_id, recipient_email = nil)
    group = Group.find_by(id: group_id)
    requestor = User.find_by(id: requestor_id)
    return unless group && requestor
    return unless GroupService.export_permitted?(group: group, actor: requestor, recipient_email: recipient_email)

    group_ids = if recipient_email
      group.all_groups.pluck(:id)
    else
      GroupService.export_group_ids(group: group, actor: requestor)
    end
    filename = GroupExportService.export(Group.where(id: group_ids), group.name)
    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(filename, 'r'),
      filename: File.basename(filename)
    )
    UserMailer.group_export_ready(requestor.id, group.name, blob.signed_id, recipient_email).deliver
    ActiveStorage::PurgeJob.set(wait: 1.week).perform_later(blob)
  ensure
    File.delete(filename) if filename && File.exist?(filename)
  end
end

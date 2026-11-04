class GroupExportCsvWorker < ApplicationJob
  def perform(group_id, requestor_id, recipient_email = nil)
    group = Group.find_by(id: group_id)
    requestor = User.find_by(id: requestor_id)
    return unless group && requestor
    return unless GroupService.export_permitted?(group: group, actor: requestor, recipient_email: recipient_email)

    csv = GroupExporter.new(group).to_csv
    filename = "#{group.full_name} CSV export #{DateTime.now.iso8601}".parameterize + ".csv"
    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new(csv),
      filename: filename,
      content_type: 'text/csv'
    )
    UserMailer.group_export_ready(requestor.id, group.full_name, blob.signed_id, recipient_email).deliver
    ActiveStorage::PurgeJob.set(wait: 1.week).perform_later(blob)
  end
end

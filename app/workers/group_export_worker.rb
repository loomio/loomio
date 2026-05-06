class GroupExportWorker
  include Sidekiq::Worker

  def perform(group_ids, group_name, actor_id)
    actor = User.find_by!(id: actor_id)
    groups = Group.where(id: group_ids)
    filename = GroupExportService.export(groups, group_name)
    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(filename, 'r'),
      filename: File.basename(filename)
    )
    UserMailer.group_export_ready(actor.id, group_name, blob.signed_id).deliver
    ActiveStorage::PurgeJob.set(wait: 1.week).perform_later(blob)
  ensure
    File.delete(filename) if filename && File.exist?(filename)
  end
end

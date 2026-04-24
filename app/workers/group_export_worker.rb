class GroupExportWorker
  include Sidekiq::Worker

  def perform(group_ids, group_name, actor_id)
    actor = User.find_by!(id:actor_id)
    groups = Group.where(id: group_ids)
    filename = GroupExportService.export(groups, group_name)
    document = Document.new(author: actor, title: filename)
    File.open(filename, 'r') do |file|
      document.file.attach(io: file, filename: File.basename(filename))
    end
    document.save!
    UserMailer.group_export_ready(actor.id, group_name, document.id).deliver
    DestroyRecordWorker.perform_at(1.week.from_now, 'Document', document.id)
  ensure
    File.delete(filename) if filename && File.exist?(filename)
  end
end

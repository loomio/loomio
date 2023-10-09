class GroupExportCsvWorker
  include Sidekiq::Worker

  def perform(group_id, actor_id)
    actor = User.find(actor_id)
    group = Group.find(group_id)
    csv = GroupExporter.new(group).to_csv 
    filename = "#{group.full_name} CSV export #{DateTime.now.iso8601}".parameterize+".csv"
    document = Document.new(author: actor, title: filename)
    document.file.attach(io: StringIO.new(csv), filename: filename)
    document.save!
    UserMailer.group_export_ready(actor.id, group.full_name, document.id).deliver
    DestroyRecordWorker.perform_at(1.week.from_now, 'Document', document.id)
  end
end

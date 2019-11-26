class GroupExportWorker
  include Sidekiq::Worker

  def perform(group_ids, group_name, actor_id)
    actor = User.find_by!(id:actor_id)
    groups = Group.where(id: group_ids)
    filename = GroupExportService.export(groups, group_name)
    document = Document.create(author: actor, file: File.open(filename), title: filename)
    UserMailer.group_export_ready(actor.id, group_name, document.id).deliver
    document.delay(queue: :low_priority, run_at: 1.week.from_now).destroy!
  end
end

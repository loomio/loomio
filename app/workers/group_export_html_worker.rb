class GroupExportHtmlWorker < ApplicationJob
  def perform(group_id, requestor_id)
    group = Group.find_by(id: group_id)
    requestor = User.find_by(id: requestor_id)
    return unless group && requestor&.can?(:export, group)

    html = ApplicationController.renderer.render(
      Views::Groups::Export.new(exporter: GroupExporter.new(group)), layout: false
    )
    filename = "#{group.full_name} HTML export #{DateTime.now.iso8601}".parameterize + ".html"
    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new(html), filename: filename, content_type: 'text/html'
    )
    UserMailer.group_export_ready(requestor.id, group.full_name, blob.signed_id).deliver
    ActiveStorage::PurgeJob.set(wait: 1.week).perform_later(blob)
  end
end

# frozen_string_literal: true

class Views::UserMailer::GroupExportReady < Views::ApplicationMailer::BaseLayout

  def initialize(blob:)
    @blob = blob
  end

  def view_template
    p do
      raw t(:"user_mailer.group_export_ready.body_html",
        url: group_export_download_url(
          @blob.signed_id(purpose: GroupExportDownload::PURPOSE, expires_in: GroupExportDownload::LIFETIME),
          @blob.filename
        ))
    end
  end
end

# frozen_string_literal: true

class Views::UserMailer::GroupExportReady < Views::ApplicationMailer::BaseLayout

  def initialize(blob:)
    @blob = blob
  end

  def view_template
    p do
      raw t(:"user_mailer.group_export_ready.body_html",
        url: rails_blob_url(@blob, disposition: "attachment"))
    end
  end
end

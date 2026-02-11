# frozen_string_literal: true

class Views::UserMailer::GroupExportReady < Views::ApplicationMailer::BaseLayout

  def initialize(document:)
    @document = document
  end

  def view_template
    p do
      raw t(:"user_mailer.group_export_ready.body_html",
        url: rails_blob_url(@document.file, disposition: "attachment"))
    end
  end
end

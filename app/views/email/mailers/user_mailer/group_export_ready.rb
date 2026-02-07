# frozen_string_literal: true

class Views::Email::Mailers::UserMailer::GroupExportReady < Views::Email::BaseLayout

  def initialize(document:)
    @document = document
  end

  def view_template
    p do
      raw t(:"user_mailer.group_export_ready.body_html",
        url: Rails.application.routes.url_helpers.rails_blob_url(@document.file, disposition: "attachment"))
    end
  end
end

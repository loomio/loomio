# frozen_string_literal: true

class Views::Chatbot::Matrix::Attachments < Views::Chatbot::Base
  def initialize(resource:)
    @resource = resource
  end

  def view_template
    return unless @resource.attachments.any?

    h4 { t(:'common.attachments') }
    ul do
      @resource.files.each do |file|
        download_url = Rails.application.routes.url_helpers.rails_blob_url(
          file, only_path: false, host: ENV['CANONICAL_HOST']
        )
        li do
          span { "\u{1F4CE}" }
          a(href: download_url, target: '_blank') { file.blob.filename.base }
        end
      end
    end
  end
end

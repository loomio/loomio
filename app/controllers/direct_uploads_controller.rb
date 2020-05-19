class DirectUploadsController < ActiveStorage::DirectUploadsController
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token

  private
  def direct_upload_json(blob)
    json = blob.as_json(root: false, methods: :signed_id).merge(
      direct_upload: {
        url: blob.service_url_for_direct_upload,
        headers: blob.service_headers_for_direct_upload
    })

    json.merge!(download_url: Rails.application.routes.url_helpers.rails_blob_path(blob, only_path: true))

    if blob.representable?
      json.merge!(preview_url: Rails.application.routes.url_helpers.rails_representation_path(blob.representation(HasRichText::PREVIEW_OPTIONS), only_path: true))
    end
    json
  end
end

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

    json.merge!(download_url: url_for(blob))

    if blob.representable?
      json.merge!(preview_url: rails_representation_path(blob.representation(HasRichText::PREVIEW_OPTIONS), only_path: true))
    end
    json
  end
end

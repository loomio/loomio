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

    if blob.image?
      json.merge!(preview_url: rails_representation_url(blob.variant(resize: "600x600>")))
    end
    json
  end
end

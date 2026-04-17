class DirectUploadsController < ActiveStorage::DirectUploadsController
  PAID_MAX_UPLOAD_BYTES  = ENV.fetch('PAID_MAX_UPLOAD_BYTES',  1.gigabyte).to_i
  TRIAL_MAX_UPLOAD_BYTES = ENV.fetch('TRIAL_MAX_UPLOAD_BYTES', 25.megabytes).to_i

  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token
  before_action :enforce_upload_size_limit, only: :create

  private

  # This controller inherits from ActiveStorage::DirectUploadsController, not our
  # ApplicationController, so CurrentUserHelper#current_user isn't in the chain.
  # Uphold the Loomio invariant that current_user is never nil.
  def current_user
    super || LoggedOutUser.new
  end

  def enforce_upload_size_limit
    return if params.dig(:blob, :byte_size).to_i <= max_upload_bytes
    render json: {
      error: I18n.t('upload.file_too_large',
                    limit: ActiveSupport::NumberHelper.number_to_human_size(max_upload_bytes))
    }, status: :unprocessable_entity
  end

  def max_upload_bytes
    current_user.is_paying? ? PAID_MAX_UPLOAD_BYTES : TRIAL_MAX_UPLOAD_BYTES
  end

  def direct_upload_json(blob)
    json = blob.as_json(root: false, methods: :signed_id).merge(
      direct_upload: {
        url: blob.service_url_for_direct_upload,
        headers: blob.service_headers_for_direct_upload
    })

    json.merge!(download_url:
      Rails.application.routes.url_helpers.rails_blob_path(blob, only_path: true)
    )

    if blob.representable?
      json.merge!(preview_url:
        Rails.application.routes.url_helpers.rails_representation_path(
          blob.representation(HasRichText::PREVIEW_OPTIONS),
          only_path: true
        )
      )
    end
    json
  end
end

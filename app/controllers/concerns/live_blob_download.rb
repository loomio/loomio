module LiveBlobDownload
  extend ActiveSupport::Concern

  included do
    prepend_before_action :no_store
  end

  private

  # Run immediately after resolving the signed ID and before processing a
  # representation or opening a storage stream.
  def set_blob
    super
    return if performed? || !BlobAttachmentAccess.required?

    head :not_found unless BlobAttachmentAccess.live?(@blob)
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end
end

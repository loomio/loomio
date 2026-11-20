class DraftUploadsController < BlobDownloadsController
  include LocalesHelper
  include CurrentUserHelper

  UPLOADER_KEY = "loomio_uploader_id"
  PREVIEW_LIFETIME = 1.hour

  def show
    proxy
  end

  private

  def set_blob
    @blob = ActiveStorage::Blob.find_signed(params[:signed_id])
    return head :not_found unless @blob && current_user.is_logged_in?

    unless @blob.metadata[UPLOADER_KEY] == current_user.id &&
           @blob.created_at > PREVIEW_LIFETIME.ago &&
           !@blob.attachments.exists?
      head :not_found
    end
  end
end

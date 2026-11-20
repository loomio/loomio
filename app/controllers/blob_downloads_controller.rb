class BlobDownloadsController < ActiveStorage::BaseController
  include ActiveStorage::SetBlob
  include LiveBlobDownload

  def redirect
    redirect_to @blob.url(disposition: params[:disposition]), allow_other_host: true
  end
end

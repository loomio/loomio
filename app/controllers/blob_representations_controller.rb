class BlobRepresentationsController < ActiveStorage::Representations::BaseController
  include ActiveStorage::Streaming
  include ActiveStorage::DisableSession
  include LiveBlobDownload

  def redirect
    redirect_to @representation.url(disposition: params[:disposition]), allow_other_host: true
  end

  def proxy
    send_blob_stream @representation, disposition: params[:disposition]
  end
end

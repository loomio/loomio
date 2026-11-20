class BlobDownloadsController < ActiveStorage::BaseController
  include ActiveStorage::SetBlob
  include ActiveStorage::Streaming
  include ActiveStorage::DisableSession
  include LiveBlobDownload

  def redirect
    redirect_to @blob.url(disposition: params[:disposition]), allow_other_host: true
  end

  def proxy
    if request.headers["Range"].present?
      send_blob_byte_range_data @blob, request.headers["Range"], disposition: params[:disposition]
    else
      response.headers["Accept-Ranges"] = "bytes"
      response.headers["Content-Length"] = @blob.byte_size.to_s
      send_blob_stream @blob, disposition: params[:disposition]
    end
  end
end

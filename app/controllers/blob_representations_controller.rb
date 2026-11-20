class BlobRepresentationsController < ActiveStorage::Representations::BaseController
  include LiveBlobDownload

  def redirect
    redirect_to @representation.url(disposition: params[:disposition]), allow_other_host: true
  end
end

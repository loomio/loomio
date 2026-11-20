class GroupExportDownloadsController < ActiveStorage::BaseController
  before_action :no_store

  def show
    blob = ActiveStorage::Blob.find_signed(params[:signed_id], purpose: GroupExportDownload::PURPOSE)
    return head :not_found unless blob

    redirect_to blob.url(disposition: :attachment), allow_other_host: true
  end
end

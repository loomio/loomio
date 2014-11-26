class API::AttachmentsController < API::RestfulController

  def credentials
    render json: UploadHelper::S3Uploader.new.fields
  end

end
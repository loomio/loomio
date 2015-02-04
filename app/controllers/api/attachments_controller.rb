class API::AttachmentsController < API::RestfulController

  def credentials
    uploader = UploadHelper::S3Uploader.new
    @credentials = uploader.fields.merge(url: uploader.url)
    render json: @credentials
  end

end
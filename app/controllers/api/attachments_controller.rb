class API::AttachmentsController < API::BaseController

  def create
    attachment = Attachment.new(permitted_params.attachment)
    attachment.user = current_user

    if attachment.save
      Measurement.increment('attachments.create.success')
      render json: attachment, root: false
    else
      Measurement.increment('attachments.create.error')
      render json: attachment.errors, root: false
    end
  end

  def credentials
    render json: UploadHelper::S3Uploader.new.fields
  end

end
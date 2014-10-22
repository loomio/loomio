class API::AttachmentsController < API::BaseController

  def create
    binding.pry
    attachment = Attachment.new(permitted_params.attachment)
    attachment.user = current_user

    if attachment.save
      Measurement.increment('attachments.create.success')
      render json: { saved: true, attachment_id: attachment.id }
    else
      Measurement.increment('attachments.create.error')
      render json: { saved: false }
    end
  end

  def credentials
    render json: UploadHelper::S3Uploader.new.fields
  end

end
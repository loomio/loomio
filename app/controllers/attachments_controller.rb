class AttachmentsController < BaseController
  skip_before_filter :authenticate_user!

  def new
    render layout: false
  end

  def create
    attachment = Attachment.new(permitted_params.attachment)
    attachment.user = current_user

    if attachment.save
      render json: { saved: true, attachment_id: attachment.id }
    else
      render json: { saved: false }
    end
  end

  def iframe_upload_result
    render layout: false
  end
end

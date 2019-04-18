class ReceivedEmailsController < Griddler::EmailsController
  force_ssl except: [:reply, :create]

  # reply to discussion by email action
  def reply
    normalized_params.each do |p|
      process_email Griddler::Email.new(p)
    end

    head :ok
  end

  def create
    if ReceivedEmailService.create(received_email: ReceivedEmail.fromJSON(received_email_params))
      head :ok
    else
      head :bad_request
    end
  end

  private

  def mailin_params
    @mailin_params ||= JSON.parse(params.require(:mailinMsg))
  end
end

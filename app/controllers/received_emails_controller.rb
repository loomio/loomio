class ReceivedEmailsController < ActionController::Base
  force_ssl except: [:create]

  def create
    if ReceivedEmailService.create(received_email: ReceivedEmail.fromJSON(params.require(:mailinMsg)))
      head :ok
    else
      head :bad_request
    end
  end
end

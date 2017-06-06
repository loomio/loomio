class ReceivedEmailsController < ApplicationController
  def create
    if ReceivedEmail.new(received_email_params).save
      head :ok
    else
      # airbrake here?
      head :bad_request
    end
  end

  private

  def received_email_params
    {
      sender_email: mailin_params.dig('from', 0, 'address'),
      headers:      mailin_params['headers'],
      subject:      mailin_params.dig('headers', 'subject'),
      body:         mailin_params['html'] || mailin_params['text'],
      locale:       mailin_params['language']
    }
  end

  def mailin_params
    @mailin_params ||= JSON.parse(params.require(:mailinMsg))
  end
end

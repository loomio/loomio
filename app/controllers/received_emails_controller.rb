class ReceivedEmailsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    email = build_received_email_from_params

    email.save!
    
    if email.is_addressed_to_loomio? && !email.is_auto_response?
      ReceivedEmailService.route(email)
    end

    head :ok
  end

  private

  def build_received_email_from_params
    data = JSON.parse(params[:mailinMsg])

    email = ReceivedEmail.new(
      headers: data['headers'],
      body_text: data['text'],
      body_html: data['html'],
      dkim_valid: data['dkim'] == 'pass' ? true : false,
      spf_valid: data['spf'] == 'pass' ? true : false,
    )

    email.attachments = data.fetch('attachments', []).map do |a|
      {
        io: StringIO.new(Base64.decode64(params[a['generatedFileName']])),
        content_type: a['contentType'],
        filename: a['generatedFileName']
      }
    end

    email
  end
end

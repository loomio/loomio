class ReceivedEmailsController < Griddler::EmailsController
  skip_before_action :verify_authenticity_token

  # reply to discussion by email action
  def reply
    unless is_autoresponse? 
      normalized_params.each do |p|
        process_email Griddler::Email.new(p)
      end
    end

    head :ok
  end

  def create
    if ReceivedEmail.new(received_email_params).save
      head :ok
    else
      head :bad_request
    end
  end

  private

  def is_autoresponse?
    return true if (mailin_params['headers'] || {}).keys.map(&:downcase).include?('x-autorespond')
    return true if mailin_params.dig('headers', 'X-Precedence') ==  'auto_reply'

    prefixes = [
      'Auto:',
      'Automatic reply',
      'Autosvar',
      'Automatisk svar',
      'Automatisch antwoord',
      'Abwesenheitsnotiz',
      'Risposta Non al computer',
      'Automatisch antwoord',
      'Auto Response',
      'Respuesta automática',
      'Fuori sede',
      'Out of Office',
      'Frånvaro',
      'Réponse automatique'
    ]

    return true if prefixes.any? do |prefix|
      (mailin_params.dig('headers', 'subject') || '').downcase.starts_with?(prefix.downcase)
    end

    false
  end

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

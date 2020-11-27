class Clients::Recaptcha < Clients::Base
  def validate(recaptcha)
    req = post_query "siteverify", params: { response: recaptcha, secret: ENV['RECAPTCHA_SECRET_KEY']}
    Rails.logger.info "recaptcha response #{req.response}" 
    req.response['success']
  end

  private

  def default_host
    "https://www.google.com/recaptcha/api"
  end

  def default_is_success
    ->(response) { response.success? && JSON.parse(response.body)['success'].present? }
  end
end

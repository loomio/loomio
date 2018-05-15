class Clients::Recaptcha < Clients::Base
  def validate(recaptcha)
    return true unless self.key
    post("siteverify", params: { response: recaptcha }).success
  end

  private

  def default_host
    "https://www.google.com/recaptcha/api"
  end

  def default_is_success
    ->(response) { response.success? && JSON.parse(response.body)['success'].present? }
  end
end

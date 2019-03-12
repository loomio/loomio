module ProtectedFromForgery

  def self.included(base)
    base.after_action :set_xsrf_token
  end

  protected

  def verified_request?
    super || form_authenticity_token == request.headers['X-CSRF-TOKEN']
  end

  private

  def set_xsrf_token
    cookies['CSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end
end

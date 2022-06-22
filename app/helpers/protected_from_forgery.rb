module ProtectedFromForgery

  def self.included(base)
    base.after_action :set_xsrf_token
  end

  protected

  def verified_request?
    super || cookies['csrftoken'] == request.headers['X-CSRF-TOKEN']
  end

  private

  def set_xsrf_token
    if protect_against_forgery?
      cookies[:csrftoken] = {
        value: form_authenticity_token,
        expires: 1.day.from_now,
        secure: true
      }
    end
  end
end

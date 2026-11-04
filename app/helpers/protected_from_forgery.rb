module ProtectedFromForgery

  def self.included(base)
    base.after_action :set_xsrf_token
  end

  protected

  def verified_request?
    Rails.env.development? || valid_xsrf_token? || super
  end

  private

  # The browser client echoes the Rails-generated token from its CSRF cookie.
  # Validate it before Rails checks the Origin header because privacy-preserving
  # browser contexts can send a null origin for an otherwise same-site request.
  def valid_xsrf_token?
    cookie_token = cookies['csrftoken']
    header_token = request.headers['X-CSRF-TOKEN']

    cookie_token.present? &&
      header_token.present? &&
      ActiveSupport::SecurityUtils.secure_compare(cookie_token, header_token) &&
      valid_authenticity_token?(session, header_token)
  end

  def set_xsrf_token
    if protect_against_forgery?
      cookies[:csrftoken] = {
        value: form_authenticity_token,
        expires: 1.day.from_now,
        secure: Rails.application.config.force_ssl,
        same_site: :lax
      }
    end
  end
end

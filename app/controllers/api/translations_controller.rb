class API::TranslationsController < API::BaseController
  def show
    locale = params[:lang].to_sym

    response = I18n.backend.send(:translations)[:en][:client]
    response = locale_with_fallback.deep_merge I18n.backend.send(:translations)[locale][:client] unless locale == :en

    render json: response
  end
end

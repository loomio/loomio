class API::TranslationsController < API::RestfulController

  class TranslationUnavailableError < Exception; end
  rescue_from(TranslationUnavailableError) { |e| respond_with_standard_error e, 400 }

  def show
    render json: translations_for(:en, params[:lang])
  end

  def inline
    params[:model] = 'motion' if params[:model] == 'proposal' # >:-o
    raise TranslationUnavailableError.new unless TranslationService.available?
    self.resource = TranslationService.new.translate(load_and_authorize(params[:model]))
    respond_with_resource
  end

  private

  def translations_for(*locales)
    locales.map(&:to_s).uniq.reduce({}) do |translations, locale|
      translations.deep_merge YAML.load_file("config/locales/client.#{locale}.yml")[locale]
    end
  end

end

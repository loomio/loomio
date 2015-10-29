class API::TranslationsController < API::RestfulController

  def show
    render json: translations_for(:en, params[:lang])
  end

  private

  def translations_for(*locales)
    locales.map(&:to_s).uniq.reduce({}) do |translations, locale|
      translations.deep_merge YAML.load_file("config/locales/client.#{locale}.yml")[locale]
    end
  end
end

class API::TranslationsController < API::RestfulController

  def show
    render json: translations_for(:en, params[:lang])
  end

  def inline
    self.resource = service.create(model: translation_model, to: params[:to])
    respond_with_resource
  end

  private

  def translation_model
    case params[:model]
    when 'proposal' then load_and_authorize(:motion)
    else                 load_and_authorize(params[:model])
    end
  end

  def translations_for(*locales)
    locales.map(&:to_s).uniq.reduce({}) do |translations, locale|
      return unless File.exist?(yml_for(locale))
      translations.deep_merge(YAML.load_file("config/locales/client.#{locale}.yml")[locale])
                  .deep_merge(Plugins::Repository.translations_for(locale))
    end
  end

  def yml_for(locale)
    "config/locales/client.#{locale}.yml"
  end

end

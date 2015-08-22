class API::TranslationsController < API::RestfulController

  class TranslationUnavailableError < Exception; end
  rescue_from(TranslationUnavailableError) { |e| respond_with_standard_error e, 400 }

  def show
    locale = params[:lang]

    source = YAML.load_file("config/locales/client.#{locale}.yml")[locale]
    fallback = YAML.load_file('config/locales/client.en.yml')['en']

    dest = fallback.deep_merge(source)
    render json: dest
  end

  def inline
    raise TranslationUnavailableError.new unless TranslationService.available?

    instance = load_and_authorize params[:model]
    self.resource = TranslationService.new.translate(instance)
    respond_with_resource
  end

end

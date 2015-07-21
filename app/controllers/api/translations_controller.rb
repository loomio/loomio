class API::TranslationsController < API::BaseController
  def show
    locale = params[:lang]

    source = YAML.load_file("config/locales/client.#{locale}.yml")[locale]
    fallback = YAML.load_file('config/locales/client.en.yml')['en']

    dest = fallback.deep_merge(source)
    render json: dest
  end
end

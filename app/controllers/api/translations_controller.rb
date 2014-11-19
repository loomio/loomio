class API::TranslationsController < API::BaseController
  def show
    locale_root = Rails.root.join('config', 'locales', "client.#{params[:lang]}.yml")
    render json: YAML.load_file(locale_root)[params[:lang]]
  end
end

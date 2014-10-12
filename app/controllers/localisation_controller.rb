class LocalisationController < ApplicationController
  skip_before_action :verify_authenticity_token
  def datetime_input_translations
  end

  def show
    render json: YAML.load_file(Rails.root.join('config', 'locales', "#{params[:locale]}.yml"))[params[:locale]]
  end
end

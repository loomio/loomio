class API::TranslationsController < API::RestfulController
  def show
    if params[:vue]
      vue_version = single_curlify(ClientTranslationService.new(params[:lang]).as_json)
      render json: vue_version
    else
      render json: ClientTranslationService.new(params[:lang]).as_json
    end
  end

  def inline
    self.resource = service.create(model: load_and_authorize(params[:model]), to: params[:to])
    respond_with_resource
  end

  def single_curlify(hash)
    hash.each do |key, value|
      if value.is_a? String
        value.gsub!('{{', '{')
        value.gsub!('}}', '}')
      elsif value.is_a? Hash
        single_curlify(value)
      end
    end
  end

end

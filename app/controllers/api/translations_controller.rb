class API::TranslationsController < API::RestfulController
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

class API::TranslationsController < API::RestfulController
  def inline
    self.resource = service.create(model: load_and_authorize(params[:model]), to: params[:to])
    respond_with_resource
  end
end

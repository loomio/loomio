class API::TranslationsController < API::RestfulController
  def show
    {
     title: "this is a title",
     other: {
       thing: "another {{title}}"
       }
     }
    if params[:vue]
      render json: convertcurlys(ClientTranslationService.new(params[:lang]).as_json
    else
      render json: ClientTranslationService.new(params[:lang]).as_json
    end
  end

  def inline
    self.resource = service.create(model: load_and_authorize(params[:model]), to: params[:to])
    respond_with_resource
  end
end

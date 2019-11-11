class API::VersionsController < API::RestfulController
  def show
    if params['use_vue']
      self.resource = model.versions[params[:index].to_i]
      respond_with_resource
    else
      self.resource = service.reduce(model: model, index: params[:index].to_i)
      respond_with_resource
    end
  end

  private

  def resource_class
    PaperTrail::Version
  end

  def model
    load_and_authorize(:group, optional:true)||
    load_and_authorize(:discussion, optional:true)||
    load_and_authorize(:comment, optional:true) ||
    load_and_authorize(:stance, optional:true) ||
    load_and_authorize(:poll, optional:false)
  end

end

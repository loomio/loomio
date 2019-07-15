class API::VersionsController < API::RestfulController
  def show
    self.resource = service.reduce(model: model, index: params[:index].to_i)
    respond_with_resource
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

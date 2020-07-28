class API::VersionsController < API::RestfulController
  def show
    self.resource = model.versions[params[:index].to_i]
    respond_with_resource(scope: default_scope.merge(exclude_types: %w[discussion group user comment poll stance]),
                          serializer: resource_serializer,
                          root: serializer_root)
  end

  private

  def resource_class
    PaperTrail::Version
  end

  def model
    load_and_authorize(:group, optional:true) ||
    load_and_authorize(:discussion, optional:true) ||
    load_and_authorize(:comment, optional:true) ||
    load_and_authorize(:stance, optional:true) ||
    load_and_authorize(:poll, optional:false)
  end

end

class API::VersionsController < API::RestfulController
  def show
    self.resource = model.versions[params[:index].to_i]
    respond_with_resource
  end

  private

  def exclude_types
    %w[discussion group user comment poll stance stance_choice]
  end

  def serializer_class
    VersionSerializer
  end

  def serializer_root
    'versions'
  end

  def model
    load_and_authorize(:group, optional:true) ||
    load_and_authorize(:discussion, optional:true) ||
    load_and_authorize(:comment, optional:true) ||
    load_and_authorize(:stance, optional:true) ||
    load_and_authorize(:poll, optional:true) ||
    load_and_authorize(:outcome, optional:false)
  end
end

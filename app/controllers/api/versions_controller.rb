class API::VersionsController < API::RestfulController
  def show
    versions = model.versions
    self.resource = versions[params[:index].to_i|| versions.count-1]
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
    load_and_authorize(:poll, optional:false)
  end


  def accessible_records
    # used to create an index of all available records
    records = load_and_authorize(params[:model]).versions.order(created_at: :desc)
    records = records.where(event: 'update') if params[:model] == 'discussion'
    records
  end

  def default_page_size
    100
  end
end

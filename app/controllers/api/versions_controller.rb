class API::VersionsController < API::RestfulController
  def show
    versions = model.versions
    index = params[:index].to_i

    versions[index].object_changes = versions.first(index+1).reduce({}) do |changes, version|
      # for each field, nil values become the latest value we changed to
      keys = model.class.always_versioned_fields;

      always_changes = keys.map do |k|
        existing = changes.dig(k, 1)
        [k, version.object_changes[k.to_s] || [existing, existing]]
      end.to_h

      version.object_changes.merge always_changes
    end
    
    self.resource = versions[index]

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

module UsesMetadata
  include AngularHelper

  def show
    if request.format == :xml
      load_resource_by_key
    else
      boot_angular_ui
    end
  end

  private

  def load_resource_by_key
    instance_variable_set "@#{controller_name.singularize}", controller_name.classify.constantize.find(params[:id] || params[:key])
  end

  def metadata
    @metadata ||= "Metadata::#{controller_name.singularize.camelize}Serializer".constantize.new(load_resource_by_key).as_json
  end
end

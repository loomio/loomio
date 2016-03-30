module UsesMetadata
  include AngularHelper
  alias :show :boot_angular_ui

  private

  def load_resource_by_key
    instance_variable_set "@#{controller_name}", controller_name.classify.constantize.find_by!(key: params[:id])
  end

  def metadata
    @metadata ||= "Metadata::#{controller_name.singularize.camelize}Serializer".constantize.new(load_resource_by_key).as_json
  end
end

module MetadataHelper

  private

  def set_metadata
    @metadata = "Metadata::#{controller_name.singularize.camelize}Serializer".constantize.new(load_resource_by_key).as_json
  end

  def load_resource_by_key
    instance_variable_set "@#{controller_name}", controller_name.classify.constantize.find_by!(params.slice(:key))
  end
end

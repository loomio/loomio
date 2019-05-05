module UsesMetadata
  def show
    metadata
    respond_to do |format|
      format.html { index }
      format.rss  { render :"show.xml" }
      format.xml
    end
  end

  private

  def metadata
    @metadata ||= if current_user.can? :show, resource
      "Metadata::#{controller_name.singularize.camelize}Serializer".constantize.new(resource)
    else
      {}
    end.as_json
  end

  def resource
    instance_variable_get("@#{resource_name}") ||
    instance_variable_set("@#{resource_name}", ModelLocator.new(resource_name, params).locate)
  end

  def resource_name
    controller_name.singularize
  end
end

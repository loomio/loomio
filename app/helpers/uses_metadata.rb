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

  def resource
    instance_variable_get("@#{resource_name}") ||
    instance_variable_set("@#{resource_name}", ModelLocator.new(resource_name, params).locate)
  end

  def resource_name
    controller_name.singularize
  end
end

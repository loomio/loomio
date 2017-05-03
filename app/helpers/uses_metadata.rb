module UsesMetadata
  include AngularHelper

  def show
    metadata
    if request.format == :xml
      # load rss feed
    else
      boot_angular_ui
    end
  end

  private

  def metadata
    @metadata ||= if metadata_user.can? :show, resource
      "Metadata::#{controller_name.singularize.camelize}Serializer".constantize.new(resource)
    else
      {}
    end.as_json
  end

  # metadata user defines who we determine can see metadata or not.
  # defaults to the current user
  # we override this when we want to be able to pass query parameters which allow
  # otherwise unauthorized users to view metadata (for example, when scraping from a facebook group)
  def metadata_user
    current_user
  end

  def resource
    instance_variable_get("@#{resource_name}") ||
    instance_variable_set("@#{resource_name}", ModelLocator.new(resource_name, params).locate)
  end

  def resource_name
    controller_name.singularize
  end
end

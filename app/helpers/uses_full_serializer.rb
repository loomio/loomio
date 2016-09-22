module UsesFullSerializer
  def resource_serializer
    case action_name
    when 'show', 'create', 'update' then "Full::#{controller_name.singularize.camelize}Serializer".constantize
    else super
    end
  end
end

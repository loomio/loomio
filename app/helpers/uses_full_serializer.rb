module UsesFullSerializer
  def resource_serializer
    case action_name
    when 'show' then show_serializer
    else super
    end
  end

  def show_serializer
    if params[:simple]
      "Simple::#{controller_name.singularize.camelize}Serializer"
    else
      "Full::#{controller_name.singularize.camelize}Serializer"
    end.constantize
  end
end

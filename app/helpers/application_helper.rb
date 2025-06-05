module ApplicationHelper
  def vue_index
    File.read(Rails.root.join('public/client3/index.html'))
  end

  def vue_css_includes
    Nokogiri::HTML(vue_index).css('head link[as=style], head link[rel=stylesheet]').to_s
  end

  def vue_js_includes
    Nokogiri::HTML(vue_index).css('head link[as=script], script').to_s
  end

  def logo_svg
    return nil unless AppConfig.theme[:app_logo_src].ends_with?('.svg')

    path = Rails.root.join('public', AppConfig.theme[:app_logo_src].gsub(Regexp.new("^/"), ''))
    File.read(path).html_safe
  end

  def metadata
    @metadata ||= if should_have_metadata && current_user.can?(:show, resource)
      "Metadata::#{controller_name.singularize.camelize}Serializer".constantize.new(resource)
    else
      {
        title: AppConfig.theme[:site_name],
        description: AppConfig.theme[:description],
        image_urls: []
      }
    end.as_json
  end

  def resource
    ModelLocator.new(resource_name, params).locate
  end

  def assign_resource
    instance_variable_get("@#{resource_name}") ||
    instance_variable_set("@#{resource_name}", resource)
  end

  def resource_name
    controller_name.singularize
  end

  def should_have_metadata
    %w{discussion group poll user}.include? controller_name.singularize.downcase
  end
end

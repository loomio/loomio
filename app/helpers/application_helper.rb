module ApplicationHelper
  def save_beta_setting!
    if current_user.present?
      if params[:beta] == "1"
        current_user.experiences['vue3'] = true
        current_user.save
      end

      if params[:beta] == "0"
        current_user.experiences['vue3'] = false
        current_user.save
      end
    end
  end

  def use_beta_client?
    params[:beta] == "1" || (current_user.present? && current_user.experiences['vue3'])
  end

  def vue_index
    if use_beta_client?
      File.read(Rails.root.join('public/client3/index.html'))
    else
      File.read(Rails.root.join('public/blient/index.html'))
    end
  end

  def vue_css_includes
    Nokogiri::HTML(vue_index).css('head link[as=style], head link[rel=stylesheet]').to_s
  end

  def vue_js_includes
    Nokogiri::HTML(vue_index).css('head link[as=script], script').to_s
  end

  def metadata
    @metadata ||= if should_have_metadata && current_user.can?(:show, resource)
      "Metadata::#{controller_name.singularize.camelize}Serializer".constantize.new(resource)
    else
      {title: AppConfig.theme[:site_name], image_urls: []}
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

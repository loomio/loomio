module ThemesHelper
  def theme_stylesheet_link_tag
    if @group and @group.theme.present?
      stylesheet_link_tag theme_assets_path(@group.theme)
    end
  end

  def theme_javascript_include_tag
    if @group and @group.theme.present?
      javascript_include_tag theme_assets_path(@group.theme)
    end
  end
end

module PagesHelper
  def css_class_active(page, control)
    css = ''
    css = 'active' if page == control
    css
  end
end

module AngularHelper

  def boot_angular_ui
    if browser.ie? && browser.version.to_i < 10
      redirect_to :browser_not_supported and return
    end
    render 'angular/index', layout: false
  end

  def use_angular_ui?
    current_user_or_visitor.angular_ui_enabled? && request.format == :html
  end

end

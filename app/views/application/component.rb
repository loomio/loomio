# frozen_string_literal: true

class Views::Application::Component < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  include PrettyUrlHelper
  include PollHelper
  include FormattedDateHelper
  include Phlex::Rails::Helpers::T
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::ImagePath
  include Phlex::Rails::Helpers::Sanitize
  include Phlex::Rails::Helpers::StyleSheetLinkTag
  include Phlex::Rails::Helpers::NumberToHumanSize

  if Rails.env.development?
    def before_template
      comment { "Before #{self.class.name}" }
      super
    end
  end

  def cache_store = Rails.cache

  private

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

  def time_ago(time, current_user)
    abbr(class: "time-ago", title: time.to_s) do
      plain format_date_for_humans(time, current_user.time_zone, current_user.date_time_pref)
    end
  end
end

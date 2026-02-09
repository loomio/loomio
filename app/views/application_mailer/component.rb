# frozen_string_literal: true

class Views::ApplicationMailer::Component < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  include PollHelper
  include FormattedDateHelper
  include Phlex::Rails::Helpers::T
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::ImagePath
  include Phlex::Rails::Helpers::Sanitize
  include Phlex::Rails::Helpers::StyleSheetLinkTag
  include Phlex::Rails::Helpers::NumberToHumanSize
  include EmailHelper

  if Rails.env.development?
    def before_template
      comment { "Before #{self.class.name}" }
      super
    end
  end

  def cache_store = Rails.cache

  private

  def time_ago(time, current_user)
    abbr(class: "time-ago", title: time.to_s) do
      plain format_date_for_humans(time, current_user.time_zone, current_user.date_time_pref)
    end
  end
end

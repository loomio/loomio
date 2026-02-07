# frozen_string_literal: true

class Views::Web::Base < Views::Base
  private

  def time_ago(time, current_user)
    abbr(class: "time-ago", title: time.to_s) do
      plain format_date_for_humans(time, current_user.time_zone, current_user.date_time_pref)
    end
  end
end

# frozen_string_literal: true

class Views::Admin::Dashboard < Views::Admin::Layout
  def initialize(stats:)
    super(title: "Dashboard")
    @stats = stats
  end

  def view_template
    page_header("Dashboard")
    div(class: "admin-stats admin-dashboard-stats") do
      @stats.each do |label, count|
        div do
          strong { count.to_fs(:delimited) }
          span { label }
        end
      end
    end
  end
end

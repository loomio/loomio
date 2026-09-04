# frozen_string_literal: true

class Views::Subscriptions::ChooseGroup < Views::BasicLayout
  def initialize(groups:)
    super(title: "Choose an organization")
    @groups = groups
  end

  def view_template
    main(class: "sistema") do
      h1 { "Choose an organization" }
      p { "Select the organization whose subscription you want to manage." }
      ul do
        @groups.each do |group|
          li { a(href: subscription_portal_group_path(group.id)) { group.full_name } }
        end
      end
    end
  end
end

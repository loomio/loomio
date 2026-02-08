# frozen_string_literal: true

class Views::UserMailer::UserAddedToGroup < Views::ApplicationMailer::BaseLayout
  include PrettyUrlHelper

  def initialize(group:, inviter:, utm_hash:)
    @group = group
    @inviter = inviter
    @utm_hash = utm_hash
  end

  def view_template
    div(class: "invite-people-mailer__context") do
      raw t(:"email.user_added_to_group.content_html", which_group: @group.full_name, who: @inviter.name)
    end
    div(class: "text-center") do
      link_to t(:"email.view_group"),
        group_url(@group, @utm_hash),
        class: "base-mailer__button base-mailer__button--accent"
    end
    div(class: "invite-people-mailer__value-proposition") do
      plain t(:"email.loomio_app_description", site_name: AppConfig.theme[:site_name])
    end
  end
end

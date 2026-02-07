# frozen_string_literal: true

class Views::Email::Mailers::UserMailer::MembershipRequestApproved < Views::Email::BaseLayout
  include PrettyUrlHelper

  def initialize(group:, utm_hash:)
    @group = group
    @utm_hash = utm_hash
  end

  def view_template
    div(class: "invite-people-mailer__context") do
      raw t(:"email.group_membership_approved.intro_html", group_name: @group.name)
    end
    div(class: "text-center") do
      link_to t(:"email.view_group"),
        group_url(@group, @utm_hash),
        class: "base-mailer__button base-mailer__button--accent"
    end
    div(class: "invite-people-mailer__value-proposition") do
      div(class: "text-caption") do
        plain t(:"email.loomio_app_description", site_name: AppConfig.theme[:site_name])
      end
    end
  end
end

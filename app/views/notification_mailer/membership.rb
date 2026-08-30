# frozen_string_literal: true

class Views::NotificationMailer::Membership < Views::NotificationMailer::Layout

  def initialize(topic_item:, recipient:, event_key:)
    @topic_item = topic_item
    @recipient = recipient
    @event_key = event_key
    @membership = topic_item.itemable
    @group = @membership.group
  end

  def view_template
    if @membership.accepted_at
      url = group_url(@membership.group)
      button_text = t(:'email.view_group')
    else
      url = membership_url(@membership)
      button_text = t(:"email.to_join_group.accept_invitation")
    end

    render Views::NotificationMailer::Common::Notification.new(
      topic_item: @topic_item,
      recipient: @recipient,
      event_key: @event_key,
      with_title: true,
      url: url,
      title: @membership.group.full_name
    )
    render Views::NotificationMailer::Group::CoverAndLogo.new(group: @group)

    h1 { plain @group.full_name }

    div do
      raw sanitize(
        MarkdownService.render_plain_text(@group.description, @group.description_format).truncate(280),
        tags: %w[p br strong em]
      )
    end

    div(class: "email-actions") do
      render Views::NotificationMailer::Common::Button.new(url: url, text: button_text)
    end

    unless @recipient.email_verified
      p { plain t(:"email.to_join_group.accepting_is_important") }
    end

    div(class: "email-branding") do
      image_tag(
        AppConfig.theme[:email_footer_logo_src],
        alt: "#{AppConfig.theme[:site_name]} logo",
        class: "email-footer-logo"
      )
      p(class: "email-caption") { plain t(:"email.loomio_app_description", site_name: AppConfig.theme[:site_name]) }
    end
  end
end

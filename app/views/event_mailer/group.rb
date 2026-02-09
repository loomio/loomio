# frozen_string_literal: true

class Views::EventMailer::Group < Views::EventMailer::EventLayout

  def initialize(event:, recipient:, event_key:)
    @event = event
    @recipient = recipient
    @event_key = event_key
    @group = event.eventable
    @membership = @group.all_memberships.find_by!(user_id: recipient.id)
  end

  def view_template
    url = membership_url(@membership)

    render Views::EventMailer::Common::Notification.new(
      event: @event,
      recipient: @recipient,
      event_key: @event_key,
      with_title: true,
      url: url
    )
    render Views::EventMailer::Group::CoverAndLogo.new(group: @group)

    h1(class: "text-h5") { plain @group.full_name }

    plain sanitize(
      MarkdownService.render_plain_text(@group.description, @group.description_format).truncate(280),
      tags: %w[p br strong em]
    )

    div(class: "px-2 py-1") do
      div(class: "text-center") do
        render Views::EventMailer::Common::Button.new(
          url: url,
          text: t(:"email.to_join_group.accept_invitation")
        )
      end
    end

    unless @recipient.email_verified
      p { plain t(:"email.to_join_group.accepting_is_important") }
    end

    div(class: "pt-4") do
      image_tag(
        AppConfig.theme[:email_footer_logo_src],
        alt: "#{AppConfig.theme[:site_name]} logo",
        class: "thread-mailer__footer-logo"
      )
      p(class: "text-caption") { plain t(:"email.loomio_app_description", site_name: AppConfig.theme[:site_name]) }
    end
  end
end

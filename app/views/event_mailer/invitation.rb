class Views::EventMailer::Invitation < Views::ApplicationMailer::Component
  def initialize(poll:, recipient:)
    @poll = poll
    @recipient = recipient
  end

  def view_template
    html do
      head { render_email_head }
      body do
        h1 { plain @poll.title }
        if @poll.event_cancelled?
          p { plain t('calendar.cancelled') }
        else
          p { plain t('calendar.response_requested') }
        end
        render Views::EventMailer::Details.new(poll: @poll, recipient: @recipient)
        p { a(href: poll_url(@poll)) { plain t(@poll.event_cancelled? ? 'calendar.view_event' : 'calendar.respond') } }
      end
    end
  end
end

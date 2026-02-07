# frozen_string_literal: true

class Views::EmailComponents::Poll::Responses < Views::Base
  include Phlex::Rails::Helpers::T
  include EmailHelper

  def initialize(event:, recipient:)
    @event = event
    @recipient = recipient
  end

  def view_template
    poll = @event.eventable.poll
    my_stance = @recipient && ::Stance.latest.find_by(poll_id: poll.id, participant_id: @recipient.id)

    if poll.show_results?(voted: my_stance && my_stance.cast_at)
      div(class: "poll-mailer-common-responses") do
        if poll.anonymous?
          p { plain t(:"poll_common_action_panel.anonymous") }
        end
      end

      table(class: "v-layout-table", cellspacing: 0) do
        poll.stances.latest.with_reason.each do |stance|
          tr do
            td(valign: "top", style: "width: 36px; height: 36px") do
              render Views::EmailComponents::Common::Avatar.new(user: stance.participant)
            end
            td(class: "poll-mailer-common-responses__reason pl-2") do
              table do
                tr do
                  td(valign: "top") do
                    strong { plain "#{stance.participant.name}:" }
                  end
                  td(valign: "top") do
                    render Views::EmailComponents::Poll::StanceChoices.new(
                      poll: poll,
                      stance: stance,
                      recipient: @recipient
                    )
                  end
                end
              end
              raw formatted_text(stance, :reason)
            end
          end
        end
      end
    else
      p { plain t(:"poll_common_action_panel.results_hidden_until_closed") }
    end
  end
end

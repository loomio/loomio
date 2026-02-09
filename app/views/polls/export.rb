# frozen_string_literal: true

class Views::Polls::Export < Views::Application::Component
  def initialize(poll:, exporter:, recipient:)
    @poll = poll
    @exporter = exporter
    @recipient = recipient
  end

  def view_template
    stylesheet_link_tag "email"
    div(class: "thread-page mt-12") do
      main(class: "v-main") do
        div(class: "v-main__wrap") do
          div do
            div(class: "container thread-page max-width-800 px-0 px-sm-3") do
              div(class: "thread-card v-card v-sheet--outlined v-sheet theme--auto pa-4") do
                render Views::Discussions::ThreadItems::PollCreated.new(item: @poll.created_event, current_user: @recipient)
                render Views::EventMailer::Poll::Responses.new(event: @poll.created_event, recipient: @recipient)
              end
            end
          end
        end
      end
    end
  end
end

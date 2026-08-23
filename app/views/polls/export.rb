# frozen_string_literal: true

class Views::Polls::Export < Views::Application::Component
  include EmailHelper

  def initialize(poll:, exporter:, recipient:)
    @poll = poll
    @exporter = exporter
    @recipient = recipient
  end

  def view_template
    style { plain email_theme_css }
    stylesheet_link_tag "vtfy/mailers"
    stylesheet_link_tag "vtfy/email_utilities"
    div(class: "thread-page mt-12") do
      main(class: "v-main") do
        div(class: "v-main__wrap") do
          div do
            div(class: "container thread-page max-width-800 px-0 px-sm-3") do
              div(class: "thread-card v-card v-sheet--outlined v-sheet theme--auto pa-4") do
                render Views::Topics::TopicItems::PollCreated.new(item: @poll.created_topic_item, current_user: @recipient)
                render Views::DeliveryMailer::Poll::Responses.new(topic_item: @poll.created_topic_item, recipient: @recipient)
              end
            end
          end
        end
      end
    end
  end
end

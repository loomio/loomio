# frozen_string_literal: true

class Views::Discussions::ThreadItems::PollCreated < Views::Base
  def initialize(item:, current_user:)
    @item = item
    @current_user = current_user
  end

  def view_template
    poll = @item.eventable
    div(class: "poll-created") do
      div(class: "thread-item px-3 pb-1") do
        div(id: "sequence-3", class: "v-layout lmo-action-dock-wrapper", style: "margin-left: 0px;") do
          div(class: "thread-item__avatar mr-3 mt-0") do
            render Views::Email::Common::Avatar.new(user: poll.user)
          end
          div(class: "thread-item__body") do
            h1(class: "poll-common-card__title text-h5 pb-1") do
              span { plain poll.title }
            end
            p(class: "text-medium-emphasis text-body-2 pb-1") do
              plain t("poll_card.poll_type_by_name", name: poll.author_name, poll_type: t("poll_types.#{poll.poll_type}"))
              span("aria-hidden": "true") { plain " \u00b7" }
              plain " "
              if poll.active?
                plain t("common.closing_in", time: format_date_for_humans(poll.closing_at, @current_user.time_zone, @current_user.date_time_pref))
              end
              if poll.closed?
                plain t("poll_common_form.closed")
                plain " "
                plain format_date_for_humans(poll.closed_at, @current_user.time_zone, @current_user.date_time_pref)
              end
              if poll.wip?
                plain t("poll_common_wip_field.title")
              end
            end
            if poll.current_outcome
              div(class: "poll-common-outcome-panel v-alert v-alert--density-default v-alert--variant-tonal text-info pa-4 my-4") do
                span(class: "v-alert__underlay")
                div(class: "v-alert__content") do
                  div(class: "title") { plain t("poll_common.outcome") }
                  div(class: "poll-common-outcome-panel__authored-by caption my-2") do
                    span { plain t("email.by_who", person: poll.current_outcome.author.name) }
                    span do
                      plain " "
                      time_ago(poll.current_outcome.created_at, @current_user)
                    end
                  end
                  div(class: "lmo-markdown-wrapper text-body-1 pb-1") do
                    p { raw MarkdownService.render_rich_text(poll.current_outcome.statement, poll.current_outcome.statement_format) }
                  end
                end
              end
            end
            div(class: "lmo-markdown-wrapper text-body-1 poll-common-details-panel__details pb-1") do
              p { raw MarkdownService.render_rich_text(poll.details, poll.details_format) }
            end
            render Views::Email::Poll::ResultsPanel.new(poll: poll, current_user: @current_user)
          end
        end
      end
    end
  end
end

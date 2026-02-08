# frozen_string_literal: true

class Views::EventMailer::Poll::Results::Meeting < Views::BaseMailer::Base

  def initialize(poll:, recipient:)
    @poll = poll
    @recipient = recipient
  end

  def view_template
    table(class: "poll-meeting-chart pb-2", cellspacing: 0) do
      thead do
        tr do
          td { plain @recipient.time_zone }
          td { plain t(:'poll_common.votes') }
          @poll.decided_voters.each do |user|
            td { render Views::EventMailer::Common::Avatar.new(user: user, size: 24) }
          end
        end
      end
      tbody do
        @poll.poll_options.each do |poll_option|
          tr do
            td(class: "poll-meeting-chart__meeting-time") do
              pre { plain option_name(poll_option.name, @poll.poll_option_name_format, @recipient.time_zone, @recipient.date_time_pref) }
            end
            td(class: "total text-center") do
              strong { plain((poll_option.total_score.to_f / 2).to_s.gsub('.0', '')) }
            end
            @poll.decided_voters.each do |user|
              td do
                score = poll_option.voter_scores.fetch(user.id.to_s, 0)
                class_for_score = case score
                when 2 then 'poll-meeting-chart__cell--yes'
                when 1 then 'poll-meeting-chart__cell--maybe'
                when 0 then 'poll-meeting-chart__cell--no'
                end
                div(class: "poll-meeting-chart__cell #{class_for_score}") do
                  span { raw "&nbsp;".html_safe }
                end
              end
            end
          end
        end
      end
    end
  end
end

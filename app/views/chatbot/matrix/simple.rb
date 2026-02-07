# frozen_string_literal: true

class Views::Chatbot::Matrix::Simple < Views::Chatbot::Base
  def initialize(poll:, recipient:)
    @poll = poll
    @recipient = recipient
  end

  def view_template
    table do
      thead do
        tr do
          @poll.result_columns.each do |col|
            case col
            when 'pie', 'bar', 'grid'
              th { @poll.closed_at ? t(:"poll_common.results") : t(:"poll_common.current_results") }
            when 'name'
              th { t('common.option') }
            when 'score_percent'
              th { t('poll_ranked_choice_form.pct_of_points') }
            when 'votes_cast_percent'
              th { t('poll_ranked_choice_form.pct_of_votes_cast') }
            when 'voter_percent'
              th { t('poll_ranked_choice_form.pct_of_voters') }
            when 'rank'
              th { t('poll_ranked_choice_form.rank') }
            when 'score'
              th { t('poll_ranked_choice_form.points') }
            when 'average'
              th { t('poll_ranked_choice_form.mean') }
            when 'voter_count'
              th { t('membership_card.voters') }
            when 'votes'
              th { t('poll_common.votes') }
            when 'voters'
              th
            end
          end
        end
      end
      tbody do
        @poll.results.each do |option|
          tr do
            @poll.result_columns.each do |col|
              case col
              when 'pie', 'bar'
                td { "\u{2592}" * (option[:max_score_percent].to_i / 10) }
              when 'grid'
                # no output
              when 'name'
                td do
                  plain option_name(option[:name], option[:name_format], @recipient.time_zone, @recipient.date_time_pref)
                end
              when 'rank'
                td { option[:rank].to_s }
              when 'score'
                td { option[:score].to_s }
              when 'voter_count', 'votes'
                td { option[:voter_count].to_s }
              when 'average'
                td { option[:average].round.to_s }
              when 'voter_percent'
                td { "#{option[:voter_percent].round}%" }
              when 'score_percent', 'votes_cast_percent'
                td { option[:score_percent].nil? ? '' : "#{option[:score_percent].round}%" }
              when 'voters'
                td do
                  User.where(id: option[:voter_ids]).each do |user|
                    render Views::Email::Common::Avatar.new(user: user, size: 24)
                  end
                  if option[:voter_ids].length == 0
                    span(style: 'display: inline-block; height: 24px') { raw '&nbsp;'.html_safe }
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

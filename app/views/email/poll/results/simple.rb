# frozen_string_literal: true

class Views::Email::Poll::Results::Simple < Views::Email::Base

  def initialize(poll:, recipient:)
    @poll = poll
    @recipient = recipient
  end

  def view_template
    results = @poll.results

    div(class: "poll-mailer-common-results") do
      table(class: "v-table", style: "min-width: 600px", cellspacing: 0) do
        tbody do
          # Header row
          tr do
            @poll.result_columns.each do |col|
              render_header_cell(col)
            end
          end

          # Data rows
          results.each_with_index do |option, index|
            tr do
              @poll.result_columns.each do |col|
                render_data_cell(col, option, index, results)
              end
            end
          end
        end
      end
    end
  end

  private

  def render_header_cell(col)
    case col
    when 'chart'
      th(class: "text-left text-subtitle-2") do
        plain(@poll.closed_at ? t(:"poll_common.results") : t(:"poll_common.current_results"))
      end
    when 'name'
      th(class: "text-left text-subtitle-2") { plain t('common.option') }
    when 'votes_cast_percent'
      th(class: "text-right text-subtitle-2") { plain t('poll_ranked_choice_form.pct_of_votes_cast') }
    when 'score_percent'
      th(class: "text-right text-subtitle-2") { plain t('poll_ranked_choice_form.pct_of_points') }
    when 'voter_percent'
      th(class: "text-right text-subtitle-2") { plain t('poll_ranked_choice_form.pct_of_voters') }
    when 'target_percent'
      th(class: "text-right text-subtitle-2") { plain t('poll_count_form.pct_of_target') }
    when 'rank'
      th(class: "text-right text-subtitle-2") { plain t('poll_ranked_choice_form.rank') }
    when 'score'
      th(class: "text-right text-subtitle-2") { plain t('poll_ranked_choice_form.points') }
    when 'average'
      th(class: "text-right text-subtitle-2") { plain t('poll_ranked_choice_form.mean') }
    when 'votes'
      th(class: "text-right text-subtitle-2") { plain t('poll_common.votes') }
    when 'voter_count'
      th(class: "text-right text-subtitle-2") { plain t('membership_card.voters') }
    when 'voters'
      th(class: "text-left text-subtitle-2")
    end
  end

  def render_data_cell(col, option, index, results)
    case col
    when 'chart'
      render_chart_cell(option, index, results)
    when 'name'
      td(style: (@poll.chart_type == 'pie') ? "border-left: solid 4px #{option[:color]}" : '') do
        case option[:name_format]
        when 'i18n'
          plain t(option[:name])
        when 'iso8601'
          plain format_iso8601_for_humans(option[:name], @recipient.time_zone, @recipient.date_time_pref)
        else
          plain TranslationService.plain_text(::PollOption.find(option[:id]), :name, @recipient)
        end
      end
    when 'rank'
      td(class: "text-right") { plain option[:rank].to_s }
    when 'score'
      td(class: "text-right") { plain option[:score].to_s }
    when 'voter_count', 'votes'
      td(class: "text-right") { plain option[:voter_count].to_s }
    when 'average'
      td(class: "text-right") { plain option[:average].round.to_s }
    when 'target_percent'
      td(class: "text-right") do
        if option[:icon] == 'agree'
          plain "#{option[:target_percent].round}%"
        end
      end
    when 'voter_percent'
      td(class: "text-right") { plain option[:voter_percent].round.to_s }
    when 'score_percent', 'votes_cast_percent'
      td(class: "text-right") { plain(option[:score_percent].nil? ? '' : option[:score_percent].round.to_s) }
    when 'voters'
      td(class: "text-left") do
        User.where(id: option[:voter_ids]).limit(20).each do |user|
          render Views::Email::Common::Avatar.new(user: user, size: 24)
        end
        if option[:voter_ids].length == 0
          span(style: "display: inline-block; height: 24px") { raw "&nbsp;".html_safe }
        end
      end
    end
  end

  def render_chart_cell(option, index, results)
    if @poll.chart_type == 'pie' && index == 0
      td(class: "pr-2 py-2", rowspan: results.size) do
        div(class: "poll-mailer-proposal__chart poll-mailer__results-chart d-flex align-center justify-center") do
          img(
            class: "poll-mailer-proposal__chart-image",
            style: "height: 128px; width: 128px",
            src: google_pie_chart_url(@poll),
            width: 128,
            height: 128
          )
        end
      end
    end

    if @poll.chart_type == 'bar'
      td(class: "pr-2 py-2", style: "width: 128px") do
        if option[@poll.chart_column] > 0
          table(cellspacing: 0, cellpadding: 0, width: "100%", height: "100%") do
            tr do
              td(
                class: "no-border rounded",
                style: "background-color: #{option[:color]}; height: 24px",
                height: 24,
                width: "#{option[@poll.chart_column].clamp(0, 100)}%"
              )
              td(class: "no-border")
            end
          end
        end
      end
    end
  end
end

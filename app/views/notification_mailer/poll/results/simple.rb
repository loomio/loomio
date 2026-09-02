# frozen_string_literal: true

class Views::NotificationMailer::Poll::Results::Simple < Views::ApplicationMailer::Component

  def initialize(poll:, recipient:)
    @poll = poll
    @recipient = recipient
  end

  def view_template
    results = @poll.results

    div do
      table(class: "email-results-table", style: "min-width: 600px", cellspacing: 0) do
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
      th(class: "email-table-left") do
        plain(@poll.closed_at ? t(:"poll_common.results") : t(:"poll_common.current_results"))
      end
    when 'name'
      th(class: "email-table-left") { plain t('common.option') }
    when 'votes_cast_percent'
      th(class: "email-table-right") { plain t('poll_ranked_choice_form.pct_of_votes_cast') }
    when 'score_percent'
      th(class: "email-table-right") { plain t('poll_ranked_choice_form.pct_of_points') }
    when 'voter_percent'
      th(class: "email-table-right") { plain t('poll_ranked_choice_form.pct_of_voters') }
    when 'target_percent'
      th(class: "email-table-right") { plain t('poll_count_form.pct_of_target') }
    when 'rank'
      th(class: "email-table-right") { plain t('poll_ranked_choice_form.rank') }
    when 'score'
      th(class: "email-table-right") { plain t('poll_ranked_choice_form.points') }
    when 'average'
      th(class: "email-table-right") { plain t('poll_ranked_choice_form.mean') }
    when 'votes'
      th(class: "email-table-right") { plain t('poll_common.votes') }
    when 'stv_status'
      th(class: "email-table-right") { plain t('poll_common.status') }
    when 'voter_count'
      th(class: "email-table-right") { plain t('membership_card.voters') }
    when 'voters'
      th(class: "email-table-left")
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
    when 'stv_status'
      status = option[:stv_status]
      status_class = case status
                     when 'elected' then "email-status--elected"
                     when 'tied' then "email-status--tied"
                     when 'not_elected' then "email-status--eliminated"
                     end
      label = status ? t("poll_stv_results.#{status}") : ''
      td(class: ["email-table-right", status_class].compact.join(" ")) { plain label }
    when 'rank'
      td(class: "email-table-right") { plain option[:rank].to_s }
    when 'score'
      td(class: "email-table-right") { plain option[:score].to_s }
    when 'voter_count', 'votes'
      td(class: "email-table-right") { plain option[:voter_count].to_s }
    when 'average'
      td(class: "email-table-right") { plain option[:average].round.to_s }
    when 'target_percent'
      td(class: "email-table-right") do
        if option[:icon] == 'agree'
          plain "#{option[:target_percent].round}%"
        end
      end
    when 'voter_percent'
      td(class: "email-table-right") { plain option[:voter_percent].round.to_s }
    when 'score_percent', 'votes_cast_percent'
      td(class: "email-table-right") { plain(option[:score_percent].nil? ? '' : option[:score_percent].round.to_s) }
    when 'voters'
      td(class: "email-table-left") do
        User.where(id: option[:voter_ids]).limit(20).each do |user|
          render Views::NotificationMailer::Common::Avatar.new(user: user, size: 24)
        end
        if option[:voter_ids].length == 0
          span(style: "display: inline-block; height: 24px") { raw "&nbsp;".html_safe }
        end
      end
    end
  end

  def render_chart_cell(option, index, results)
    if @poll.chart_type == 'pie' && index == 0
      td(class: "email-result-chart-cell", rowspan: results.size) do
        div(class: "email-result-chart") do
          img(

            style: "height: auto; width: 128px",
            src: google_pie_chart_url(@poll),
            width: 128
          )
        end
      end
    end

    if @poll.chart_type == 'bar'
      td(class: "email-result-chart-cell", style: "width: 128px") do
        if option[@poll.chart_column] > 0
          table(cellspacing: 0, cellpadding: 0, width: "100%", height: "100%") do
            tr do
              td(
                class: "email-result-bar",
                style: "height: 24px",
                height: 24,
                width: "#{option[@poll.chart_column].clamp(0, 100)}%"
              )
              td(class: "email-result-bar-rest")
            end
          end
        end
      end
    end
  end
end

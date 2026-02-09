# frozen_string_literal: true

class Views::EventMailer::Poll::Results::Stv < Views::ApplicationMailer::Component

  def initialize(poll:, recipient:)
    @poll = poll
    @recipient = recipient
  end

  def view_template
    stv = @poll.stv_results
    return unless stv

    # Method/quota info
    method_name = t("poll_stv_results.method_#{stv['method']}")
    quota_name = t("poll_stv_results.quota_#{stv['quota_type']}")
    p(style: "color: #666; font-style: italic") do
      plain t('poll_stv_results.quota_info', method: method_name, quota_type: quota_name, quota: format_quota(stv['quota']))
    end

    # Winners
    elected = stv['elected'] || []
    if elected.any?
      h4 { plain t('poll_stv_results.elected') }
      table(cellspacing: 0, style: "margin-bottom: 16px") do
        elected.each do |e|
          tr do
            td(style: "padding: 4px 8px; color: green; font-weight: bold") do
              plain e['name']
            end
            td(style: "padding: 4px 8px; color: #666") do
              plain t('poll_stv_results.elected_in_round', round: e['round_elected'])
            end
          end
        end
      end
    end

    # Round-by-round table
    rounds = stv['rounds'] || []
    candidates = @poll.poll_options
    return unless rounds.any?

    all_elected_ids = elected.map { |e| e['poll_option_id'] }
    all_eliminated_ids = rounds.flat_map { |r| r['eliminated'] || [] }

    table(class: "v-table", style: "min-width: 600px; border-collapse: collapse", cellspacing: 0) do
      tbody do
        # Header row
        tr do
          th(style: "text-align: left; padding: 4px 8px; border-bottom: 2px solid #ccc") do
            plain t('poll_stv_results.round', number: '').strip
          end
          candidates.each do |c|
            style = "text-align: right; padding: 4px 8px; border-bottom: 2px solid #ccc"
            style += "; color: green" if all_elected_ids.include?(c.id)
            th(style: style) { plain c.name }
          end
        end

        # Data rows
        elected_so_far = []
        eliminated_so_far = []
        rounds.each do |round|
          elected_so_far += (round['elected'] || [])
          eliminated_so_far += (round['eliminated'] || [])

          tr do
            td(style: "padding: 4px 8px; font-weight: bold; border-bottom: 1px solid #eee") do
              plain round['round'].to_s
            end
            candidates.each do |c|
              tally = round['tallies']&.dig(c.id.to_s)
              elected_this_round = (round['elected'] || []).include?(c.id)
              eliminated_this_round = (round['eliminated'] || []).include?(c.id)
              was_eliminated = eliminated_so_far.include?(c.id) && !eliminated_this_round
              was_elected = elected_so_far.include?(c.id) && !elected_this_round

              cell_style = "text-align: right; padding: 4px 8px; border-bottom: 1px solid #eee"
              if elected_this_round
                cell_style += "; color: green; font-weight: bold"
              elsif eliminated_this_round
                cell_style += "; color: #c00; text-decoration: line-through"
              elsif was_eliminated || was_elected
                cell_style += "; color: #ccc"
              end

              td(style: cell_style) do
                plain tally ? format_tally(tally) : '-'
              end
            end
          end
        end

        # Quota row
        tr do
          td(style: "padding: 4px 8px; font-style: italic; border-top: 2px solid #ccc") do
            plain "Quota"
          end
          candidates.each do
            td(style: "text-align: right; padding: 4px 8px; font-style: italic; border-top: 2px solid #ccc") do
              plain format_quota(stv['quota'])
            end
          end
        end
      end
    end
  end

  private

  def format_tally(value)
    value == value.to_i ? value.to_i.to_s : value.round(2).to_s
  end

  def format_quota(value)
    return '0' unless value
    value == value.to_i ? value.to_i.to_s : value.round(2).to_s
  end
end

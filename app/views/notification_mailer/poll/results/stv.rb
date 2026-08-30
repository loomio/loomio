# frozen_string_literal: true

class Views::NotificationMailer::Poll::Results::Stv < Views::ApplicationMailer::Component

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
    p(style: "font-style: italic") do
      plain t('poll_stv_results.quota_info', method: method_name, quota_type: quota_name, quota: format_quota(stv['quota']))
    end

    # Winners
    elected = stv['elected'] || []
    rounds = stv['rounds'] || []
    quota_val = stv['quota']
    if elected.any?
      h4 { plain t('poll_stv_results.elected') }
      table(cellspacing: 0, style: "border-collapse: collapse; margin-bottom: 16px") do
        tr do
          th(class: "email-table__header email-table-left") { plain t('poll_stv_results.candidate') }
          th(class: "email-table__header email-table-right") { plain t('poll_stv_results.round_elected') }
          th(class: "email-table__header email-table-right") { plain t('poll_stv_results.first_preferences') }
          th(class: "email-table__header email-table-right") { plain t('poll_stv_results.final_tally') }
          th(class: "email-table__header email-table-right") { plain t('poll_stv_results.quota_surplus') }
        end
        elected.each do |e|
          cid = e['poll_option_id'].to_s
          first_pref = rounds.any? ? rounds[0]['tallies']&.dig(cid) : nil
          elected_round = rounds.find { |r| r['round'] == e['round_elected'] }
          final_tally = elected_round ? elected_round['tallies']&.dig(cid) : nil
          surplus = final_tally && quota_val ? final_tally - quota_val : nil
          tr do
            td(class: "email-table__cell email-status--elected") { plain e['name'] }
            td(class: "email-table__cell email-table-right") { plain e['round_elected'].to_s }
            td(class: "email-table__cell email-table-right") { plain first_pref ? format_tally(first_pref) : '-' }
            td(class: "email-table__cell email-table-right") { plain final_tally ? format_tally(final_tally) : '-' }
            td(class: "email-table__cell email-table-right") { plain surplus ? format_tally(surplus) : '-' }
          end
        end
      end
    end

    # Tied candidates
    tied = stv['tied'] || []
    if tied.any?
      h4 { plain t('poll_stv_results.tied') }
      table(cellspacing: 0, style: "border-collapse: collapse; margin-bottom: 16px") do
        tr do
          th(class: "email-table__header email-table-left") { plain t('poll_stv_results.candidate') }
          th(class: "email-table__header email-table-right") { plain t('poll_stv_results.first_preferences') }
        end
        tied.each do |e|
          cid = e['poll_option_id'].to_s
          first_pref = rounds.any? ? rounds[0]['tallies']&.dig(cid) : nil
          tr do
            td(class: "email-table__cell email-status--tied") { plain e['name'] }
            td(class: "email-table__cell email-table-right") { plain first_pref ? format_tally(first_pref) : '-' }
          end
        end
      end
    end

    # Round-by-round table
    candidates = @poll.poll_options
    return unless rounds.any?

    all_elected_ids = elected.map { |e| e['poll_option_id'] }
    all_eliminated_ids = rounds.flat_map { |r| r['eliminated'] || [] }
    all_tied_ids = tied.map { |e| e['poll_option_id'] }

    table(class: "email-results-table", style: "border-collapse: collapse", cellspacing: 0) do
      tbody do
        # Header row: Candidate, Round 1, Round 2, ...
        tr do
          th(class: "email-table__header email-table-left") do
            plain t('poll_stv_results.candidate')
          end
          rounds.each do |round|
            th(class: "email-table__header email-table-right") do
              plain round['round'].to_s
            end
          end
        end

        # Data rows: one per candidate
        elected_so_far = []
        eliminated_so_far = []
        round_state = rounds.map do |round|
          elected_so_far += (round['elected'] || [])
          eliminated_so_far += (round['eliminated'] || [])
          { elected_so_far: elected_so_far.dup, eliminated_so_far: eliminated_so_far.dup }
        end

        candidates.each do |c|
          tr do
            name_classes = ["email-table__cell"]
            name_classes << "email-status--elected" if all_elected_ids.include?(c.id)
            name_classes << "email-status--tied" if all_tied_ids.include?(c.id)
            td(class: name_classes.join(" ")) { plain c.name }

            rounds.each_with_index do |round, i|
              tally = round['tallies']&.dig(c.id.to_s)
              elected_this_round = (round['elected'] || []).include?(c.id)
              eliminated_this_round = (round['eliminated'] || []).include?(c.id)
              tied_this_round = (round['tied'] || []).include?(c.id)
              was_elected = i > 0 && round_state[i - 1][:elected_so_far].include?(c.id)
              was_eliminated = i > 0 && round_state[i - 1][:eliminated_so_far].include?(c.id)

              cell_classes = ["email-table__cell", "email-table-right"]
              if elected_this_round
                cell_classes << "email-status--elected"
              elsif eliminated_this_round
                cell_classes << "email-status--eliminated"
              elsif tied_this_round
                cell_classes << "email-status--tied"
              elsif was_eliminated || was_elected
                cell_classes << "email-status--inactive"
              end

              td(class: cell_classes.join(" ")) do
                plain tally ? format_tally(tally) : '-'
              end
            end
          end
        end

        # Quota row
        tr do
          td(class: "email-table__quota") do
            plain "Quota"
          end
          rounds.each do
            td(class: "email-table__quota email-table-right") do
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

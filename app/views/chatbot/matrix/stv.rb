# frozen_string_literal: true

class Views::Chatbot::Matrix::Stv < Views::Chatbot::Base
  def initialize(poll:, recipient:)
    @poll = poll
    @recipient = recipient
  end

  def view_template
    stv = @poll.stv_results
    return unless stv

    elected = stv['elected'] || []

    # Winners table
    if elected.any?
      h5 { t('poll_stv_results.elected') }
      table do
        thead do
          tr do
            th { t('poll_stv_results.candidate') }
            th { t('poll_stv_results.round', number: '').strip }
          end
        end
        tbody do
          elected.each do |e|
            tr do
              td { strong { e['name'] } }
              td { e['round_elected'].to_s }
            end
          end
        end
      end
    end

    # Round-by-round table
    rounds = stv['rounds'] || []
    candidates = @poll.poll_options
    if rounds.any?
      elected_so_far = []
      eliminated_so_far = []

      table do
        thead do
          tr do
            th { t('poll_stv_results.round', number: '').strip }
            candidates.each do |c|
              th { c.name }
            end
          end
        end
        tbody do
          rounds.each do |round|
            elected_so_far += (round['elected'] || [])
            eliminated_so_far += (round['eliminated'] || [])

            tr do
              td { round['round'].to_s }
              candidates.each do |c|
                tally = round['tallies']&.dig(c.id.to_s)
                elected_this_round = (round['elected'] || []).include?(c.id)
                eliminated_this_round = (round['eliminated'] || []).include?(c.id)
                was_out = (eliminated_so_far.include?(c.id) && !eliminated_this_round) ||
                          (elected_so_far.include?(c.id) && !elected_this_round)

                td do
                  if elected_this_round
                    strong { format_number(tally) }
                    plain " \u2713"
                  elsif eliminated_this_round
                    s { format_number(tally) }
                    plain " \u2717"
                  elsif was_out
                    plain '-'
                  else
                    plain tally ? format_number(tally) : '-'
                  end
                end
              end
            end
          end
        end
      end

      p { plain "Quota: #{format_number(stv['quota'])}" }
      p { plain "\u2713 = #{t('poll_stv_results.elected')}, \u2717 = #{t('poll_stv_results.not_elected')}" }
    end

    # Method/quota info
    method_name = t("poll_stv_results.method_#{stv['method']}")
    quota_name = t("poll_stv_results.quota_#{stv['quota_type']}")
    p do
      em do
        plain t('poll_stv_results.quota_info',
               method: method_name,
               quota_type: quota_name,
               quota: format_number(stv['quota']))
      end
    end

    p { link_to t('poll_stv_results.view_full_results'), polymorphic_url(@poll) }
  end

  private

  def format_number(value)
    return '0' unless value
    value == value.to_i ? value.to_i.to_s : value.round(2).to_s
  end
end

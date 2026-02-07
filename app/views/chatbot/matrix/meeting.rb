# frozen_string_literal: true

class Views::Chatbot::Matrix::Meeting < Views::Chatbot::Base
  def initialize(poll:, recipient:)
    @poll = poll
    @recipient = recipient
  end

  def view_template
    table do
      thead do
        tr do
          td { @poll.time_zone }
          td { t(:'poll_common.votes') }
          @poll.decided_voters.each do |user|
            td { render Views::Email::Common::Avatar.new(user: user, size: 24) }
          end
        end
      end
      tbody do
        @poll.poll_options.each do |poll_option|
          tr do
            td { option_name(poll_option.name, @poll.poll_option_name_format, @recipient.time_zone, @recipient.date_time_pref) }
            td { strong { ((poll_option.total_score.to_f) / 2).to_s.gsub('.0', '') } }
            @poll.decided_voters.each do |user|
              td do
                score = poll_option.voter_scores.fetch(user.id.to_s, 0)
                plain "\u{2593}\u{2593}" if score == 2
                plain "\u{2591}\u{2591}" if score == 1
              end
            end
          end
        end
      end
    end
    plain "\u{2593}\u{2593} #{t('poll_meeting_vote_form.can_attend')}.\n"
    plain "\u{2591}\u{2591} #{t('poll_meeting_vote_form.if_need_be')}.\n"
    plain "#{t('common.empty')} #{t('poll_meeting_vote_form.unable')}.\n"
  end
end

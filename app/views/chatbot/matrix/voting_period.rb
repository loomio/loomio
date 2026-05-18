# frozen_string_literal: true

class Views::Chatbot::Matrix::VotingPeriod < Views::Chatbot::Base
  def initialize(poll:, recipient:)
    @poll = poll
    @recipient = recipient
  end

  def view_template
    if @poll.scheduled?
      days = ((@poll.closing_at - @poll.opening_at) / 1.day).round
      p { plain t('poll_mailer.common.voting_opens_and_closes', opens: format_date_for_humans(@poll.opening_at, @recipient.time_zone, @recipient.date_time_pref), closes: format_date_for_humans(@poll.closing_at, @recipient.time_zone, @recipient.date_time_pref), days: days) }
    elsif @poll.active?
      p { plain t('poll_mailer.common.you_have_until', when: format_date_for_humans(@poll.closing_at, @recipient.time_zone, @recipient.date_time_pref)) }
    elsif @poll.closed? && @poll.opened_at
      days = ((@poll.closed_at - @poll.opened_at) / 1.day).round
      p { plain t('poll_mailer.common.voting_opened_and_closed', opens: format_date_for_humans(@poll.opened_at, @recipient.time_zone, @recipient.date_time_pref), closes: format_date_for_humans(@poll.closed_at, @recipient.time_zone, @recipient.date_time_pref), days: days) }
    end
  end
end

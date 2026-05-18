# frozen_string_literal: true

class Views::EventMailer::Poll::VotingPeriod < Views::ApplicationMailer::Component

  def initialize(poll:, recipient:)
    @poll = poll
    @recipient = recipient
  end

  def view_template
    if @poll.scheduled?
      days = ((@poll.closing_at - @poll.opening_at) / 1.day).round
      p(class: "text-subtitle-2") do
        plain t('poll_mailer.common.voting_opens_and_closes',
          opens: format_date_for_humans(@poll.opening_at, @recipient.time_zone, @recipient.date_time_pref),
          closes: format_date_for_humans(@poll.closing_at, @recipient.time_zone, @recipient.date_time_pref),
          days: days)
      end
    elsif @poll.active?
      stance = recipient_stance(@recipient, @poll)
      if stance && !stance.cast_at
        p(class: "text-subtitle-2") do
          plain t('poll_mailer.common.you_have_until',
            when: format_date_for_humans(@poll.closing_at, @recipient.time_zone, @recipient.date_time_pref))
        end
      else
        p(class: "text-subtitle-2") do
          plain t('poll_mailer.common.voting_closes',
            when: format_date_for_humans(@poll.closing_at, @recipient.time_zone, @recipient.date_time_pref))
        end
      end
    elsif @poll.closed? && @poll.opened_at
      days = ((@poll.closed_at - @poll.opened_at) / 1.day).round
      p(class: "text-subtitle-2") do
        plain t('poll_mailer.common.voting_opened_and_closed',
          opens: format_date_for_humans(@poll.opened_at, @recipient.time_zone, @recipient.date_time_pref),
          closes: format_date_for_humans(@poll.closed_at, @recipient.time_zone, @recipient.date_time_pref),
          days: days)
      end
    end
  end
end

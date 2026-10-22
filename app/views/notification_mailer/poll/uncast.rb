# frozen_string_literal: true

class Views::NotificationMailer::Poll::Uncast < Views::ApplicationMailer::Component

  def initialize(poll:)
    @poll = poll
  end

  def view_template
    nom = @poll.votes_cast_count
    dnom = @poll.voters_eligible_count
    pct = dnom > 0 ? (nom.to_f / dnom.to_f * 100).to_i : 0

    p(class: "email-poll-meta") do
      plain t('poll_common_percent_voted.pct_participation', num: nom, total: dnom, pct: pct)
    end
  end
end

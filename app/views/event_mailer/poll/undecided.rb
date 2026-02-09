# frozen_string_literal: true

class Views::EventMailer::Poll::Undecided < Views::ApplicationMailer::Component

  def initialize(poll:)
    @poll = poll
  end

  def view_template
    nom = @poll.decided_voters_count
    dnom = @poll.voters_count
    pct = dnom > 0 ? (nom.to_f / dnom.to_f * 100).to_i : 0

    p(class: "text-subtitle-2") do
      plain t('poll_common_percent_voted.pct_participation', num: nom, total: dnom, pct: pct)
    end
  end
end

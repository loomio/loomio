# frozen_string_literal: true

class Views::NotificationMailer::Poll::Undecided < Views::ApplicationMailer::Component

  def initialize(poll:)
    @poll = poll
  end

  def view_template
    nom = @poll.decided_voters_count
    dnom = @poll.voters_count
    pct = @poll.cast_stances_pct

    p(class: "email-poll-meta") do
      plain t(@poll.participation_key, num: nom, total: dnom, pct: pct)
    end
  end
end

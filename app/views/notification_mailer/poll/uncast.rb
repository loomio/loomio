# frozen_string_literal: true

class Views::NotificationMailer::Poll::Uncast < Views::ApplicationMailer::Component

  def initialize(poll:)
    @poll = poll
  end

  def view_template
    nom = @poll.vote_count_cast
    dnom = @poll.vote_count_eligible
    pct = @poll.participation_pct

    p(class: "email-poll-meta") do
      plain t(@poll.participation_key, num: nom, total: dnom, pct: pct)
    end
  end
end

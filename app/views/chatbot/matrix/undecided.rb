# frozen_string_literal: true

class Views::Chatbot::Matrix::Undecided < Views::Chatbot::Base
  def initialize(poll:)
    @poll = poll
  end

  def view_template
    nom = @poll.decided_voters_count
    dnom = @poll.voters_count
    pct = dnom > 0 ? (nom.to_f / dnom.to_f * 100).to_i : 0

    p { t('poll_common_percent_voted.pct_participation', num: nom, total: dnom, pct: pct) }

    if @poll.active? && @poll.undecided_voters.any?
      h5 { t('poll.waiting_for_votes_from') }
      p { @poll.undecided_voters.map(&:username).join(', ') }
    end
  end
end

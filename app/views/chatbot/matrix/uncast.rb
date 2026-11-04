# frozen_string_literal: true

class Views::Chatbot::Matrix::Uncast < Views::Chatbot::Base
  def initialize(poll:)
    @poll = poll
  end

  def view_template
    nom = @poll.vote_count_cast
    dnom = @poll.vote_count_eligible
    pct = @poll.participation_pct

    p { t(@poll.participation_key, num: nom, total: dnom, pct: pct) }

    if @poll.active? && @poll.voters_uncast.any?
      h5 { t('poll.waiting_for_votes_from') }
      p { @poll.voters_uncast.map(&:username).join(', ') }
    end
  end
end

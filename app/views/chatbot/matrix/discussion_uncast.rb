# frozen_string_literal: true

class Views::Chatbot::Matrix::DiscussionUncast < Views::Chatbot::Base
  def initialize(itemable:)
    @itemable = itemable
  end

  def view_template
    usernames = @itemable.polls.map(&:voters_uncast).flatten.uniq.map(&:username)
    return unless usernames.any?

    h5 { t('poll.waiting_for_votes_from') }
    p { usernames.join(', ') }
  end
end

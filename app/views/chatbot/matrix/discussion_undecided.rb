# frozen_string_literal: true

class Views::Chatbot::Matrix::DiscussionUndecided < Views::Chatbot::Base
  def initialize(itemable:)
    @itemable = itemable
  end

  def view_template
    usernames = @itemable.polls.map(&:undecided_voters).flatten.uniq.map(&:username)
    return unless usernames.any?

    h5 { t('poll.waiting_for_votes_from') }
    p { usernames.join(', ') }
  end
end

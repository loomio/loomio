# frozen_string_literal: true

class Views::Chatbot::Matrix::DiscussionUndecided < Views::Chatbot::Base
  def initialize(eventable:)
    @eventable = eventable
  end

  def view_template
    usernames = @eventable.polls.map(&:undecided_voters).flatten.uniq.map(&:username)
    return unless usernames.any?

    h5 { t('poll.waiting_for_votes_from') }
    p { usernames.join(', ') }
  end
end

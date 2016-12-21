class API::PollDidNotVotesController < API::RestfulController

  private

  def accessible_records
    load_and_authorize(:poll).poll_did_not_votes
  end

end

class API::DidNotVotesController < API::RestfulController

  private

  def accessible_records
    load_and_authorize(:motion).did_not_votes.order(:id)
  end

end

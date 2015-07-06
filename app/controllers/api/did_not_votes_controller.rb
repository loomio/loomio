class API::DidNotVotesController < API::RestfulController

  private

  def visible_records
    load_and_authorize :motion
    @motion.did_not_votes.order(:id)
  end

end

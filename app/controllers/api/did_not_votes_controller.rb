class API::DidNotVotesController < API::RestfulController

  def create
    raise NotImplementedError.new
  end

  def update
    raise NotImplementedError.new
  end

  def destroy
    raise NotImplementedError.new
  end

  private

  def visible_records
    load_and_authorize :motion
    @motion.did_not_votes.order(:id)
  end

end

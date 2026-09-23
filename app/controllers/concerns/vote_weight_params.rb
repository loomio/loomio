module VoteWeightParams
  private

  # Bulk weight updates accept only record IDs mapped to scalar weights. The
  # services validate each weight against the shared decimal range and scale.
  def vote_weights_by_record_id
    weights = params.require(:weights)
    raise ActionController::BadRequest, 'weights must be a map' unless weights.is_a?(ActionController::Parameters)

    weights.each_pair.to_h do |id, weight|
      unless id.match?(/\A[1-9]\d*\z/) && (weight.is_a?(String) || weight.is_a?(Numeric))
        raise ActionController::BadRequest, 'weights must map record IDs to values'
      end
      [id, weight]
    end
  end
end

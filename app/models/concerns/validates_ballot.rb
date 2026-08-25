module ValidatesBallot
  extend ActiveSupport::Concern

  included do
    validate :ballot_is_valid
  end

  private

  # Ballot integrity depends on the submitted choices as a set. Validate the
  # effective poll bounds for every poll type, then apply rules such as dot
  # totals and contiguous rankings that cannot be expressed by scalar bounds.
  def ballot_is_valid
    return unless ballot_validation_required?
    return unless poll

    validator = BallotValidator.new(
      poll: poll,
      choices: ballot_choices_for_validation,
      none_of_the_above: none_of_the_above
    )
    ballot_error_add if validator.reasons.any?
  end

  def ballot_error_add
    errors.add(ballot_choices_error_attribute, :invalid) unless errors.added?(ballot_choices_error_attribute, :invalid)
  end
end

class Api::V1::AnonymousBallotsController < Api::V1::RestfulController
  def create
    reject_unsupported_parameters!
    ballot_params = resource_params
    poll = Poll.find(ballot_params[:poll_id])
    ballot = poll.anonymous_ballots.build(
      none_of_the_above: ActiveModel::Type::Boolean.new.cast(ballot_params[:none_of_the_above]) || false,
      anonymous_ballot_choices_attributes: ballot_params[:anonymous_ballot_choices_attributes]
    )

    AnonymousBallotService.create(anonymous_ballot: ballot, actor: current_user)
    render json: { recorded: true }, root: false
  end

  private

  def reject_unsupported_parameters!
    ballot_params = params.require(:anonymous_ballot)
    raise ActionController::ParameterMissing, :anonymous_ballot unless ballot_params.respond_to?(:keys)

    ballot_keys = ballot_params.keys.map(&:to_s)
    unsupported = ballot_keys - %w[poll_id none_of_the_above anonymous_ballot_choices_attributes]
    raise ActionController::UnpermittedParameters, unsupported if unsupported.any?

    choices = ballot_params[:anonymous_ballot_choices_attributes] || []
    unless choices.is_a?(Array) && choices.all? { |choice| choice.respond_to?(:keys) }
      raise ActionController::UnpermittedParameters, [:anonymous_ballot_choices_attributes]
    end

    unsupported_choice_keys = choices.flat_map { |choice| choice.keys.map(&:to_s) }.uniq - %w[poll_option_id score]
    raise ActionController::UnpermittedParameters, unsupported_choice_keys if unsupported_choice_keys.any?
  end

  def accessible_records
    AnonymousBallot.none
  end
end

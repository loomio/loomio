class Api::V1::TrialsController < Api::V1::RestfulController
  def create
    trial = Trial.new(trial_params)

    trial.current_user = current_user

    if trial.valid?
      user = trial.current_or_create_user
      group = trial.create_group
      group_path = group.handle ? group_handle_path(group.handle) : group_path(group)
      render json: { group_path: group_path }
    else
      render json: { errors: trial.errors.as_json }, status: :unprocessable_entity
    end
  end

  private
  def trial_params
    params.delete(:trial)
    params.delete(:format) # I really dont know where these params come from
    params.permit(
      :user_name,
      :user_email,
      :user_email_newsletter,
      :user_legal_accepted,
      :group_name,
      :group_description,
      :group_category,
      :group_how_did_you_hear_about_loomio,
    )
  end
end

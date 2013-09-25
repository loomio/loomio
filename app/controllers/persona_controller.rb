class PersonaController < ApplicationController
  def verify
    validator = PersonaValidator.new(params[:assertion], request.host_with_port)
    result = {}

    if validator.valid?
      persona = Persona.for_email(validator.email)
      result[:status] = :good

      if user = persona.user
        sign_in(:user, user)
        flash[:notice] = t(:signed_in)
        result[:redirect_to] = after_sign_in_path_for(user)
      else
        session[:persona_id] = persona.id
        result[:redirect_to] = new_user_registration_path
      end
    else
      result[:status] = :bad
      result[:redirect_to] = root_path
      flash[:error] = t(:persona_validation_failed)
    end

    render json: result
  end
end

class PersonaController < ApplicationController
  def verify
    validator = PersonaValidator.new(params[:assertion])
    if validator.valid?
      persona = Persona.for_email(validator.email)

      if user = persona.user
        sign_in(:user, user)
        flash[:notice] = t(:signed_in)
        redirect_to after_sign_in_path_for(user)
      else
        session[:persona_id] = persona.id
        redirect_to new_user_registration_path
      end
    else
      flash[:error] = t(:persona_validation_failed)
      redirect_to new_user_session_path
    end
  end
end

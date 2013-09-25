class PersonaController < ApplicationController
  def verify
    validator = PersonaValidator.new(params[:assertion])
    if validator.valid?
      persona = Persona.for_email(validator.email)

      if user = persona.user
        set_flash_message(:notice, :signed_in) if is_navigational_format?
        sign_in(:user, user)
        respond_with user, :location => after_sign_in_path_for(user)
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

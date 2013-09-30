class PersonaController < ApplicationController
  include PersonaHelper
  include InvitationsHelper
  def verify
    next_page = root_path
    status = :bad

    validator = PersonaValidator.new(params[:assertion], request.host_with_port)

    if validator.valid?
      persona = Persona.for_email(validator.email)
      status = :good

      if persona.user
        flash[:notice] = t(:signed_in)
        sign_in(:user, persona.user)
        next_page = after_sign_in_path_for(persona.user)
      else
        save_persona_in_session(persona)
        next_page = login_or_signup_path_for_email(persona.email)
      end
    else
      flash[:error] = t(:persona_validation_failed)
    end

    render json: {status: status, redirect_to: next_page}
  end
end

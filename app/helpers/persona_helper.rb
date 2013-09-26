module PersonaHelper
  def visitor_is_persona_authenticated?
    session.has_key?(:persona_id)
  end

  def load_persona_from_session
    @persona = Persona.find(session[:persona_id])
  end

  def link_persona_to_current_user
    load_persona_from_session
    @persona.user = current_user
    @persona.save!
    clear_persona_from_session
  end

  def save_persona_in_session(persona)
    session[:persona_id] = persona.id
  end

  def clear_persona_from_session
    session.delete(:persona_id)
  end
end

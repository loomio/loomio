module TranslationsHelper
  
  def translate_link_for(model, css='')
    model_name = model.class.to_s.downcase
    link_to t(:translate_this_string, language: current_language), translate_path(model_name, model.id_field), method: :post, remote: true, class: "translate-link #{css}", id: "translate-#{model_name}-#{model.id_field}" 
  end
  
  def get_translation(translation, field, show_error = true)
    message = if valid_translation? translation, field 
                translation[field]
              elsif show_error                         
                t(:failed_translation)
              else                                          
                '' 
              end
    escape_javascript(message).html_safe
  end
  
  private
  
  def valid_translation?(translation, field)
    translation.present? && translation.has_key?(field)
  end
  
end

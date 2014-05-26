class TranslationsController < ApplicationController

  def create
    model = case params[:model].to_s.downcase
    when 'discussion' then Discussion
    when 'comment' then Comment
    when 'motion' then Motion
    when 'vote' then Vote
    end

    if model.present?
      model_name = model.to_s.downcase
      instance = model.get_instance params[:id]
      
      authorize! :show, instance
  
      @translation = TranslationService.new.translate(instance).as_json.with_indifferent_access if TranslationService.available?
      render :template => "#{model_name.pluralize}/#{model_name}_translations"
    else
      head :bad_request
    end
  end

end
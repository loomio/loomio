class TranslationsController < ApplicationController
 
  def create  
    model = params[:model].to_s.downcase
    instance = model.humanize.constantize.get_instance(params[:id])
    authorize! :show, instance

    @translation = TranslationService.new.translate(instance).as_json.with_indifferent_access if TranslationService.available?
    render :template => "#{model.pluralize}/#{model}_translations"
  end
  
end
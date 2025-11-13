class Api::V1::TranslationsController < Api::V1::RestfulController
  def inline
    self.resource = service.create(model: load_and_authorize(params[:model]), to: params[:to])
    respond_with_resource
  end

  private
  def count_collection
    false
  end
end

class API::VersionsController < API::RestfulController

  private

  def resource_class
    PaperTrail::Version
  end

  def accessible_records
    records = load_and_authorize(params[:model]).versions.order(created_at: :desc)
    records = records.where(event: 'update') if params[:model] == 'discussion'
    records
  end

  def default_page_size
    100
  end
end

class API::EventsController < API::RestfulController

  private

  def visible_records
    load_and_authorize_discussion
    Event.where(discussion: @discussion).order(:created_at)
  end

  def default_page_size
    50
  end

end

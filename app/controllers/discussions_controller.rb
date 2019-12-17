class DiscussionsController < ApplicationController
  include UsesMetadata
  include LoadAndAuthorize
  include EmailHelper
  helper :email

  def export
    @discussion = load_and_authorize(:discussion, :show)
    byebug
    respond_to do |format|
      format.html
      # format.csv { send_data @exporter.to_csv, filename:@exporter.file_name }
    end
  end
end

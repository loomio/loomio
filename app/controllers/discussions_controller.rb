class DiscussionsController < ApplicationController
  include UsesMetadata
  include LoadAndAuthorize
  include EmailHelper
  helper :email

  def export
    @discussion = load_and_authorize(:discussion, :show)
    @info = DiscussionEmailInfo.new(recipient: current_user, event: @discussion.created_event, action_name: 'new_discussion')
    byebug
    respond_to do |format|
      format.html
      # format.csv { send_data @exporter.to_csv, filename:@exporter.file_name }
    end
  end
end

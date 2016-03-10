class DiscussionsController < ApplicationController
  before_filter :we_dont_serve_images_here_google_bot
  skip_before_filter :boot_angular_ui, only: :print

  def print
    @discussion = Discussion.published.find_by_key!(params[:id])
    @group = @discussion.group
    @motions = @discussion.motions.order(&:created_at)
    @activity = @discussion.items
    render :layout => "print"
  end

  private

  def we_dont_serve_images_here_google_bot
    if request.format == :png
      render :text => 'Not Found', :status => '404'
    end
  end

  def load_resource_by_key
    @discussion ||= Discussion.published.find_by!(key: params[:id])
  end

  def metadata
    @metadata ||= Metadata::DiscussionSerializer.new(load_resource_by_key).as_json
  end
end

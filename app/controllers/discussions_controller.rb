class DiscussionsController < ApplicationController
  def show
    resource = ModelLocator.new(resource_name, params).locate!
    @recipient = current_user
    if current_user.can? :show, resource
      assign_resource
      @topic = @discussion.topic
      respond_to do |format|
        format.html do
          if params[:export] || browser.bot?
            render_topic(@topic, canonical: @discussion)
          else
            boot_app(resource: @discussion)
          end
        end
        format.xml { render 'topics/show' }
      end
    else
      respond_with_error 403
    end
  end

end

class DiscussionsController < ApplicationController
  def show
    resource = ModelLocator.new(resource_name, params).locate!
    @recipient = current_user
    if current_user.can? :show, resource
      assign_resource
      @topic = @discussion.topic
      @pagination = pagination_params
      respond_to do |format|
        format.html do
          render Views::Topics::Show.new(
            topic: @topic, recipient: @recipient, pagination: @pagination,
            metadata: metadata, export: !!params[:export], bot: browser.bot?
          )
        end
        format.xml { render 'topics/show' }
      end
    else
      respond_with_error 403
    end
  end

end

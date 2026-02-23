class DiscussionsController < ApplicationController
  def show
    resource = ModelLocator.new(resource_name, params).locate!
    @recipient = current_user
    if current_user.can? :show, resource
      assign_resource
      @pagination = pagination_params
      respond_to do |format|
        format.html do
          render Views::Discussions::Show.new(
            discussion: @discussion, recipient: @recipient, pagination: @pagination,
            metadata: metadata, export: !!params[:export], bot: browser.bot?
          )
        end
        format.xml
      end
    else
      respond_with_error 403
    end
  end

  def comment
    comment = Comment.find(params[:id])
    return respond_with_error(403) unless current_user.can?(:show, comment)

    topic = comment.topic
    sequence_id = comment.created_event&.sequence_id

    case topic.topicable
    when Discussion
      redirect_to discussion_path(topic.topicable, sequence_id: sequence_id), status: :moved_permanently
    when Poll
      redirect_to poll_path(topic.topicable, sequence_id: sequence_id), status: :moved_permanently
    else
      respond_with_error 404
    end
  rescue ActiveRecord::RecordNotFound
    respond_with_error 404
  end
end

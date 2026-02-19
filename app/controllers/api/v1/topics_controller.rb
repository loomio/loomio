class Api::V1::TopicsController < Api::V1::RestfulController
  def mark_as_read
    @topic = Topic.find(params[:id])
    authorize_topic!

    RetryOnError.with_limit(2) do
      sequence_ids = RangeSet.ranges_to_list(RangeSet.to_ranges(params[:ranges]))
      NotificationService.viewed_events(actor_id: current_user.id, topic_id: @topic.id, sequence_ids: sequence_ids)
      reader = TopicReader.for_model(@topic.topicable, current_user)
      reader.viewed!(params[:ranges])
    end
    respond_ok
  end

  private

  def authorize_topic!
    case @topic.topicable_type
    when 'Discussion'
      current_user.ability.authorize!(:mark_as_read, @topic.topicable)
    when 'Poll'
      current_user.ability.authorize!(:show, @topic.topicable)
    end
  end
end

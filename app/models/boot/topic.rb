module Boot
  class Topic
    def initialize(topicable:, user:, params:)
      @topicable = topicable
      @user = user
      @params = params
    end

    def payload
      query_params = initial_params
      records = TopicItemsQuery.new(topic: @topicable.topic, user: @user, params: query_params).collection.to_a
      exclude_types = query_params.fetch(:exclude_types, '').split(' ')
      scope = { cache: RecordCache.for_collection(records, @user.id, exclude_types), current_user_id: @user.id, exclude_types: exclude_types }
      {
        params: query_params,
        records: ActiveModel::ArraySerializer.new(records, each_serializer: TopicItemSerializer, root: :topic_items, scope: scope).as_json
      }
    end

    private

    # Match the thread page's first window, including links to a specific reply.
    # Only these parameters control bootstrap data; arbitrary API filters do not.
    def initial_params
      key_name = @topicable.is_a?(::Poll) ? :poll_key : :discussion_key
      result = { key_name => @topicable.key, include_polls_not_closed: 1, limit: 25 }
      result[:exclude_types] = 'group' if @user.is_logged_in?
      legacy_comment_link = @params[:slug] == 'comment'
      sequence_id = @params[:sequence_id].to_s[/\A[+-]?\d+/]&.to_i unless legacy_comment_link
      comment_id = (@params[:comment_id] || (@params[:sequence_id] if legacy_comment_link)).to_i
      if sequence_id
        result.merge(sequence_id_gte: [sequence_id - 12, 0].max, order: 'sequence_id')
      elsif comment_id != 0
        result.merge(comment_id: comment_id, order: 'sequence_id')
      else
        result.merge(unread_or_newest: 1)
      end
    end
  end
end

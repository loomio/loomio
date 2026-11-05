module Boot
  # Preload only the main page content. Navigation and notifications stay async.
  # Keep the API's query scopes, serializer exclusions and pagination metadata:
  # these responses enter the client through its normal record import path.
  class Page
    def initialize(user:, page:, params:, topicable: nil)
      @user = user
      @page = page
      @params = params
      @topicable = topicable
      @requests = []
    end

    def payload
      if @topicable
        @requests << Boot::Topic.new(topicable: @topicable, user: @user, params: @params).payload.merge(path: '/api/v1/topic_items')
      end

      if @user.is_logged_in?
        case @page
        when 'dashboard'
          add_topics({from: 0, per: 30, order: 'id', exclude_types: 'reaction'}, limit: 30)
          params = {from: 0, per: 25, order: 'id', exclude_types: 'reaction', status: 'recent'}
          polls = PollQuery.filter(chain: PollQuery.relevant_to(user: @user), params: params, user: @user).order(created_at: :desc, id: :desc)
          add('polls', params, polls.limit(25), PollSerializer, total: polls.count)
        when 'inbox'
          add_topics({unread: 1, per: 50}, limit: 50)
        end
      end

      defaults = @params.slice(:locale, :membership_token, :stance_token, :topic_reader_token).to_h
      @requests.each { |request| request[:params].merge!(defaults) }
      {requests: @requests}
    end

    private

    def add_topics(params, limit:)
      topics = TopicQuery.relevant_to(user: @user, or_subgroups: false, only_unread: params.key?(:unread)).recent_activity_first
      add('topics', params, topics.limit(limit), TopicSerializer, total: topics.count)
    end

    def add(path, params, records, serializer, total:)
      records = records.to_a
      exclude_types = params.fetch(:exclude_types, '').split(' ')
      scope = {cache: RecordCache.for_collection(records, @user.id, exclude_types), current_user_id: @user.id, exclude_types: exclude_types}
      json = ActiveModel::ArraySerializer.new(records, each_serializer: serializer, root: path, scope: scope,
        meta: {root: path, total: total}).as_json
      @requests << {path: "/api/v1/#{path}", params: params, records: json}
    end
  end
end

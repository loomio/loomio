module Boot
  # Preload only the main page content. Navigation and notifications stay async.
  # Keep the API's query scopes, serializer exclusions and pagination metadata:
  # these responses enter the client through its normal record import path.
  class Page
    def initialize(user:, page:, params:, resource: nil)
      @user = user
      @page = page
      @params = params
      @resource = resource
      @requests = []
    end

    def payload
      case @resource
      when ::Group
        add_group(@resource)
      when ::Discussion, ::Poll
        @requests << Boot::Topic.new(topicable: @resource, user: @user, params: @params).payload.merge(path: '/api/v1/topic_items')
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

    def add_group(group)
      @user.ability.authorize!(:show, group)
      identifier = @params[:key] || @params[:id]
      add("groups/#{identifier}", {}, [group], GroupSerializer, root: 'groups', total: nil)
      return unless @page == 'group_discussions'

      page = @params[:page].to_i
      offset = [page - 1, 0].max * 25
      params = {
        group_id: group.id, exclude_types: 'reaction', topicable_type: 'Discussion',
        subgroups: 'mine', per: 25, from: offset
      }
      params[:filter] = @params[:t].presence || 'unlocked' unless @params[:t] == 'all'
      params[:tags] = @params[:tag] if @params[:tag]
      add_topics(params, limit: 25, offset: offset)
    end

    def add_topics(params, limit:, offset: 0)
      topics = TopicListQuery.new(user: @user, params: params).records
      add('topics', params, topics.limit(limit).offset(offset), TopicSerializer, total: topics.count)
    end

    def add(path, params, records, serializer, total:, root: path)
      records = records.to_a
      exclude_types = params.fetch(:exclude_types, '').split(' ')
      scope = {cache: RecordCache.for_collection(records, @user.id, exclude_types), current_user_id: @user.id, exclude_types: exclude_types}
      json = ActiveModel::ArraySerializer.new(records, each_serializer: serializer, root: root, scope: scope,
        meta: {root: root, total: total}).as_json
      @requests << {path: "/api/v1/#{path}", params: params, records: json}
    end
  end
end

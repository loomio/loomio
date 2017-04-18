angular.module('loomioApp').factory 'PollRecordsInterface', (BaseRecordsInterface, PollModel) ->
  class PollRecordsInterface extends BaseRecordsInterface
    model: PollModel

    fetchByDiscussion: (discussionKey, options = {}) ->
      options['discussion_id'] = discussionKey
      @fetch
        params: options

    fetchClosedByGroup: (groupKey, options = {}) ->
      @search _.merge(options, {group_key: groupKey, status: 'inactive'})

    search: (options = {}) ->
      @fetch
        path: 'search'
        params: options

    searchResultsCount: ->
      @fetch path: 'search_results_count'

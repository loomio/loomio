angular.module('loomioApp').factory 'PollRecordsInterface', ($q, BaseRecordsInterface, PollModel) ->
  class PollRecordsInterface extends BaseRecordsInterface
    model: PollModel

    fetchByDiscussion: (discussionKey, options = {}) ->
      options['discussion_id'] = discussionKey
      @fetch
        params: options

    fetchClosedByGroup: (groupKey, options = {}) ->
      options['group_key'] = groupKey
      @fetch
        path: 'closed'
        params: options

    search: (groupKey, fragment, options = {}) ->
      return $q.when() unless fragment
      options['group_key'] = groupKey
      options['q'] = fragment
      @fetch
        path: 'search'
        params: options

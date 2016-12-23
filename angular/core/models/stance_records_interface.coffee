angular.module('loomioApp').factory 'StanceRecordsInterface', (BaseRecordsInterface, StanceModel) ->
  class StanceRecordsInterface extends BaseRecordsInterface
    model: StanceModel

    fetchMyStancesByDiscussion: (discussionKey, options = {}) ->
      options['discussion_id'] = discussionKey
      @fetch
        path: 'my_stances'
        params: options

angular.module('loomioApp').factory 'VisitorRecordsInterface', (BaseRecordsInterface, VisitorModel) ->
  class VisitorRecordsInterface extends BaseRecordsInterface
    model: VisitorModel

    fetchByPoll: (pollKey, options = {}) ->
      options['poll_id'] = pollKey
      @fetch
        params: options

    remind: (user, comment, success) ->
      @remote.postMember comment.id, "unlike"

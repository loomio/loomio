angular.module('loomioApp').factory 'DiscussionRecordsInterface', (BaseRecordsInterface, DiscussionModel) ->
  class DiscussionRecordsInterface extends BaseRecordsInterface
    model: DiscussionModel

    fetchByGroup: (options = {}) ->
      @fetch
        params: options

    fetchDashboard: (options = {}) ->
      @fetch
        path: 'dashboard'
        params: options

    fetchInbox: (options = {}) ->
      @fetch
        path: 'inbox'
        params: options

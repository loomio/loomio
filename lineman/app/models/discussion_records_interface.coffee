angular.module('loomioApp').factory 'DiscussionRecordsInterface', (BaseRecordsInterface, DiscussionModel) ->
  class DiscussionRecordsInterface extends BaseRecordsInterface
    model: DiscussionModel

    fetchByGroup: (options = {}) ->
      @restfulClient.getCollection
        group_id: options['group_id']
        from:     options['from']
        per:      options['per']

    fetchDashboard: (options = {}) ->
      @restfulClient.get 'discussions_for_dashboard', options

    fetchInbox: (options = {}) ->
      @restfulClient.get 'discussions_for_inbox', options

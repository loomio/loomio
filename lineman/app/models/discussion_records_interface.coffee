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

    findByDiscussionIds: (ids) ->
      @collection.chain().find({id: { $in: ids} })

    forInbox: (group) ->
      @collection.chain().find({groupId: { $in: group.organizationIds() }})

    unread: ->
      @collection.where (discussion) -> discussion.isUnread()
